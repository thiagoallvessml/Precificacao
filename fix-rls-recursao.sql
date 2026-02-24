-- ============================================
-- FIX: Corrigir recursão infinita na RLS de perfis_usuarios
-- Execute este script no Supabase SQL Editor
-- ============================================

-- 1. Primeiro, criar uma função SECURITY DEFINER que verifica se é admin sem usar RLS
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM perfis_usuarios
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;

-- 2. Remover TODAS as policies existentes de perfis_usuarios para recomeçar limpo
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT policyname FROM pg_policies WHERE tablename = 'perfis_usuarios' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.perfis_usuarios', pol.policyname);
    END LOOP;
END;
$$;

-- 3. Garantir que RLS está habilitado
ALTER TABLE public.perfis_usuarios ENABLE ROW LEVEL SECURITY;

-- 4. Policy: Cada usuário pode VER seu próprio perfil (sem recursão)
CREATE POLICY "Usuarios veem proprio perfil"
ON public.perfis_usuarios
FOR SELECT
USING (id = auth.uid());

-- 5. Policy: Admins podem ver TODOS os perfis (usa função SECURITY DEFINER, sem recursão)
CREATE POLICY "Admins veem todos perfis"
ON public.perfis_usuarios
FOR SELECT
USING (public.is_admin());

-- 6. Policy: Cada usuário pode atualizar seu próprio perfil
CREATE POLICY "Usuarios atualizam proprio perfil"
ON public.perfis_usuarios
FOR UPDATE
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- 7. Policy: Admins podem atualizar qualquer perfil
CREATE POLICY "Admins atualizam qualquer perfil"
ON public.perfis_usuarios
FOR UPDATE
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 8. Policy: Inserir perfil (para criação automática do perfil)
CREATE POLICY "Usuarios inserem proprio perfil"
ON public.perfis_usuarios
FOR INSERT
WITH CHECK (id = auth.uid());

-- 9. Policy: Admins podem inserir qualquer perfil
CREATE POLICY "Admins inserem qualquer perfil"
ON public.perfis_usuarios
FOR INSERT
WITH CHECK (public.is_admin());

-- 10. Verificar se a função get_user_role já existe (usada pelo auth-guard)
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS text
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM perfis_usuarios WHERE id = auth.uid();
$$;

-- ============================================
-- PRONTO! As policies agora usam is_admin() que é
-- SECURITY DEFINER e não dispara RLS novamente.
-- ============================================
