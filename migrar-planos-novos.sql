-- ============================================================
-- Migrar planos: free/premium → basic/intermediario/avancado
-- Execute no Supabase SQL Editor
-- ============================================================

-- 1. Remover o CHECK constraint antigo
ALTER TABLE perfis_usuarios 
DROP CONSTRAINT IF EXISTS perfis_usuarios_plano_check;

-- 2. Adicionar novo CHECK com os 3 planos (mantém legado free/premium também)
ALTER TABLE perfis_usuarios 
ADD CONSTRAINT perfis_usuarios_plano_check 
CHECK (plano IN ('basic', 'intermediario', 'avancado', 'free', 'premium'));

-- 3. Migrar usuários existentes: free → basic, premium → avancado
UPDATE perfis_usuarios SET plano = 'basic'    WHERE plano = 'free';
UPDATE perfis_usuarios SET plano = 'avancado' WHERE plano = 'premium';

-- 4. Ajustar DEFAULT da coluna para 'basic'
ALTER TABLE perfis_usuarios 
ALTER COLUMN plano SET DEFAULT 'basic';

-- 5. Agora remove os valores legados do CHECK (opcional — só faça depois de confirmar a migração)
-- ALTER TABLE perfis_usuarios 
-- DROP CONSTRAINT perfis_usuarios_plano_check;
-- ALTER TABLE perfis_usuarios 
-- ADD CONSTRAINT perfis_usuarios_plano_check 
-- CHECK (plano IN ('basic', 'intermediario', 'avancado'));

-- 6. Atualizar função admin_atualizar_usuario para aceitar novos planos
CREATE OR REPLACE FUNCTION public.admin_atualizar_usuario(
    p_user_id UUID,
    p_role TEXT DEFAULT NULL,
    p_plano TEXT DEFAULT NULL,
    p_premium_inicio TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_caller_role TEXT;
    v_result JSON;
BEGIN
    -- Verificar se quem está chamando é admin
    SELECT role INTO v_caller_role 
    FROM public.perfis_usuarios 
    WHERE id = auth.uid();
    
    IF v_caller_role != 'admin' THEN
        RAISE EXCEPTION 'Acesso negado: apenas admins podem usar esta função';
    END IF;
    
    -- Validar plano (incluindo legado)
    IF p_plano IS NOT NULL AND p_plano NOT IN ('basic', 'intermediario', 'avancado', 'free', 'premium') THEN
        RAISE EXCEPTION 'Plano inválido: use "basic", "intermediario" ou "avancado"';
    END IF;
    
    -- Validar role
    IF p_role IS NOT NULL AND p_role NOT IN ('admin', 'dono', 'afiliado') THEN
        RAISE EXCEPTION 'Role inválido: use "admin", "dono" ou "afiliado"';
    END IF;
    
    -- Atualizar o usuário (bypassa RLS pois função é SECURITY DEFINER)
    UPDATE public.perfis_usuarios
    SET
        role = COALESCE(p_role, role),
        plano = COALESCE(p_plano, plano),
        premium_inicio = CASE 
            WHEN p_plano = 'avancado' THEN COALESCE(p_premium_inicio, NOW())
            WHEN p_plano IN ('basic', 'intermediario') THEN NULL
            ELSE premium_inicio
        END
    WHERE id = p_user_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Usuário não encontrado: %', p_user_id;
    END IF;
    
    -- Retornar sucesso
    SELECT json_build_object(
        'sucesso', true,
        'user_id', p_user_id,
        'role', p_role,
        'plano', p_plano
    ) INTO v_result;
    
    RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_atualizar_usuario TO authenticated;

-- 7. Atualizar trigger para novos cadastros usarem 'basic'
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.perfis_usuarios (
        id, nome, email, role, telefone, nome_negocio, plano, trial_expires_at
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'nome', NEW.raw_user_meta_data->>'full_name', ''),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'role', 'dono'),
        COALESCE(NEW.raw_user_meta_data->>'telefone', ''),
        COALESCE(NEW.raw_user_meta_data->>'nome_negocio', ''),
        'basic',                         -- começa como basic
        NOW() + INTERVAL '7 days'        -- com 7 dias de trial avançado
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Verificar resultado
SELECT 
    id,
    nome,
    email,
    role,
    plano,
    trial_expires_at,
    CASE 
        WHEN plano = 'avancado' THEN '⭐ Avançado'
        WHEN plano = 'intermediario' THEN '🟡 Intermediário'
        WHEN trial_expires_at > NOW() THEN CONCAT('⏳ Trial (', CEIL(EXTRACT(EPOCH FROM (trial_expires_at - NOW())) / 86400)::TEXT, 'd restantes)')
        ELSE '🔵 Básico'
    END AS status_acesso
FROM perfis_usuarios
ORDER BY created_at DESC;

SELECT '✅ Planos migrados: basic / intermediario / avancado!' AS resultado;
