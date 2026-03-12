-- ============================================================
-- FIX: Admin não consegue alterar plano de outro usuário
-- 
-- CAUSA PROVÁVEL: A policy 'admin_update_all' pode não estar
-- funcionando corretamente porque current_user_role() lê a 
-- própria tabela perfis_usuarios sem garantir que o RLS
-- não interfira, ou o role do admin não está sendo reconhecido.
--
-- SOLUÇÃO: Criar função RPC SECURITY DEFINER que bypassa RLS
-- completamente para que o admin possa alterar qualquer perfil.
-- Execute no Supabase SQL Editor
-- ============================================================

-- PASSO 1: Diagnóstico — verificar as policies atuais
SELECT 
    policyname, 
    cmd, 
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'perfis_usuarios'
ORDER BY cmd, policyname;

-- PASSO 2: Verificar se a função current_user_role está correta
SELECT prosrc FROM pg_proc WHERE proname = 'current_user_role';

-- ============================================================
-- SOLUÇÃO DEFINITIVA: Criar função RPC para admin alterar plano
-- Esta função roda com SECURITY DEFINER → bypassa RLS totalmente
-- ============================================================

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
    
    -- Validar plano
    IF p_plano IS NOT NULL AND p_plano NOT IN ('free', 'premium') THEN
        RAISE EXCEPTION 'Plano inválido: use "free" ou "premium"';
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
            WHEN p_plano = 'premium' THEN COALESCE(p_premium_inicio, NOW())
            WHEN p_plano = 'free' THEN NULL
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

-- Garantir que todos os usuários autenticados podem chamar a função
-- (a verificação de admin está dentro da função)
GRANT EXECUTE ON FUNCTION public.admin_atualizar_usuario TO authenticated;

-- ============================================================
-- TAMBÉM CORRIGIR AS POLICIES para garantir que admin funciona
-- ============================================================

-- Remover e recriar a policy de update do admin com lógica mais robusta
DROP POLICY IF EXISTS "admin_update_all" ON public.perfis_usuarios;

-- Recriar usando a função SECURITY DEFINER
CREATE POLICY "admin_update_all"
ON public.perfis_usuarios FOR UPDATE
USING (public.current_user_role() = 'admin')
WITH CHECK (public.current_user_role() = 'admin');

-- Verificar se as policies existem corretamente
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'perfis_usuarios'
ORDER BY cmd, policyname;

SELECT '✅ Função admin_atualizar_usuario criada com sucesso!' AS resultado;

-- ============================================================
-- TESTE: Verificar o estado atual dos usuários
-- ============================================================
SELECT 
    id,
    nome,
    email, 
    role,
    plano,
    trial_expires_at,
    CASE 
        WHEN plano = 'premium' THEN '🌟 Premium'
        WHEN trial_expires_at > NOW() THEN CONCAT('⏳ Trial (', CEIL(EXTRACT(EPOCH FROM (trial_expires_at - NOW())) / 86400)::TEXT, 'd restantes)')
        ELSE '🔒 Free'
    END AS status_acesso
FROM perfis_usuarios
ORDER BY created_at DESC;
