-- ============================================================
-- TRIAL DE 7 DIAS: Migração completa
-- Execute no Supabase SQL Editor
-- ============================================================

-- 1. Adicionar coluna trial_expires_at na tabela perfis_usuarios
ALTER TABLE perfis_usuarios 
ADD COLUMN IF NOT EXISTS trial_expires_at TIMESTAMPTZ;

-- 2. Para usuários EXISTENTES que ainda não têm trial definido,
--    setar trial como já expirado (trial é só para novos cadastros)
UPDATE perfis_usuarios
SET trial_expires_at = NOW() - INTERVAL '1 day'
WHERE trial_expires_at IS NULL;

-- 3. Atualizar o trigger handle_new_user para conceder 7 dias de trial
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
        'free',                          -- começa como free
        NOW() + INTERVAL '7 days'        -- mas com 7 dias de trial premium
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Recriar o trigger (já existe, só atualiza a função acima)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 5. Verificar resultado
SELECT 
    id,
    nome,
    email,
    plano,
    trial_expires_at,
    CASE 
        WHEN plano = 'premium' THEN '🌟 Premium'
        WHEN trial_expires_at > NOW() THEN CONCAT('⏳ Trial (', CEIL(EXTRACT(EPOCH FROM (trial_expires_at - NOW())) / 86400)::TEXT, ' dias restantes)')
        ELSE '🔒 Free'
    END AS status_acesso
FROM perfis_usuarios
ORDER BY created_at DESC;

SELECT '✅ Trial de 7 dias configurado com sucesso!' AS resultado;
