-- ============================================================
-- FIX: Admin Dashboard não consegue carregar usuários (RLS bloqueando)
-- Execute no Supabase SQL Editor
-- ============================================================

-- PASSO 1: Diagnóstico — verificar policies atuais em perfis_usuarios
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'perfis_usuarios'
ORDER BY cmd, policyname;

-- PASSO 2: Criar função RPC para admin listar todos os usuários (bypassa RLS)
CREATE OR REPLACE FUNCTION admin_listar_usuarios(p_role TEXT DEFAULT NULL)
RETURNS SETOF perfis_usuarios
LANGUAGE plpgsql
SECURITY DEFINER  -- Executa como dono da função, bypassa RLS
SET search_path = public
AS $$
BEGIN
    -- Verificar se quem chama é admin
    IF NOT EXISTS (
        SELECT 1 FROM perfis_usuarios
        WHERE id = auth.uid() AND role = 'admin'
    ) THEN
        RAISE EXCEPTION 'Acesso negado: apenas administradores podem listar todos os usuários';
    END IF;

    -- Retornar todos os usuários (com filtro opcional de role)
    IF p_role IS NOT NULL AND p_role != '' THEN
        RETURN QUERY
            SELECT * FROM perfis_usuarios
            WHERE role = p_role
            ORDER BY created_at DESC;
    ELSE
        RETURN QUERY
            SELECT * FROM perfis_usuarios
            ORDER BY created_at DESC;
    END IF;
END;
$$;

-- Dar permissão para usuários autenticados chamarem a função
GRANT EXECUTE ON FUNCTION admin_listar_usuarios(TEXT) TO authenticated;

-- PASSO 3: Verificar se a função foi criada
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_name = 'admin_listar_usuarios'
  AND routine_schema = 'public';

SELECT '✅ Função admin_listar_usuarios criada com sucesso!' AS resultado;
