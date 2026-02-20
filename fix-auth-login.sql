-- ============================================================
-- FIX COMPLETO: Resolver loop de redirecionamento no login admin
-- Execute TODAS estas queries no Supabase SQL Editor
-- ============================================================

-- 1. Recriar a função get_user_role (SECURITY DEFINER = ignora RLS)
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
BEGIN
    RETURN (
        SELECT role FROM public.perfis_usuarios
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Recriar a função is_admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        SELECT role = 'admin' FROM public.perfis_usuarios
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Limpar TODAS as políticas existentes (para evitar conflitos)
DROP POLICY IF EXISTS "Usuarios podem ver proprio perfil" ON perfis_usuarios;
DROP POLICY IF EXISTS "Usuarios podem editar proprio perfil" ON perfis_usuarios;
DROP POLICY IF EXISTS "Admin pode ver todos os perfis" ON perfis_usuarios;
DROP POLICY IF EXISTS "Admin pode editar todos os perfis" ON perfis_usuarios;
DROP POLICY IF EXISTS "Service role pode inserir perfis" ON perfis_usuarios;

-- 4. Garantir que RLS está habilitado
ALTER TABLE perfis_usuarios ENABLE ROW LEVEL SECURITY;

-- 5. Recriar políticas de forma simples e funcional

-- SELECT: Cada usuário vê seu próprio perfil
CREATE POLICY "select_own_profile"
    ON perfis_usuarios
    FOR SELECT
    USING (auth.uid() = id);

-- SELECT: Admin vê todos (usando função SECURITY DEFINER para evitar recursão)
CREATE POLICY "admin_select_all"
    ON perfis_usuarios
    FOR SELECT
    USING (public.is_admin());

-- UPDATE: Cada usuário edita seu próprio perfil
CREATE POLICY "update_own_profile"
    ON perfis_usuarios
    FOR UPDATE
    USING (auth.uid() = id);

-- UPDATE: Admin edita todos
CREATE POLICY "admin_update_all"
    ON perfis_usuarios
    FOR UPDATE
    USING (public.is_admin());

-- INSERT: Permitir via trigger (cadastro)
CREATE POLICY "insert_profile"
    ON perfis_usuarios
    FOR INSERT
    WITH CHECK (true);

-- DELETE: Somente admin
CREATE POLICY "admin_delete"
    ON perfis_usuarios
    FOR DELETE
    USING (public.is_admin());

-- ============================================================
-- 6. Verificar se tudo ficou OK
-- ============================================================

SELECT 'Políticas atuais:' AS info;
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'perfis_usuarios';

SELECT 'Perfis existentes:' AS info;
SELECT id, nome, email, role, ativo FROM perfis_usuarios;

SELECT 'Teste da função get_user_role:' AS info;
SELECT public.get_user_role() AS role_atual;

SELECT '✅ Fix aplicado com sucesso!' AS resultado;
