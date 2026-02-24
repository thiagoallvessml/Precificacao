-- ============================================================
-- FIX DEFINITIVO: Recursão infinita no RLS de perfis_usuarios
-- 
-- CAUSA: is_admin() consulta perfis_usuarios dentro de uma
-- policy de perfis_usuarios → loop infinito.
--
-- SOLUÇÃO: Usar auth.jwt() para verificar o role do admin
-- sem precisar consultar perfis_usuarios novamente.
-- Execute NO Supabase SQL Editor
-- ============================================================

-- PASSO 1: Remover TODAS as policies existentes
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'perfis_usuarios' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.perfis_usuarios', pol.policyname);
    END LOOP;
END;
$$;

-- PASSO 2: Criar função is_admin SEM consultar perfis_usuarios
-- Usa app_metadata do JWT (definido no trigger do Supabase Auth)
-- Se não houver app_metadata, usa raw_user_meta_data como fallback
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  -- Lê o role diretamente do JWT sem tocar em nenhuma tabela
  SELECT COALESCE(
    (auth.jwt() ->> 'user_role') = 'admin',
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin',
    false
  );
$$;

-- PASSO 3: Criar função get_user_role simples (SECURITY DEFINER, sem RLS)
-- Esta função BYPASSA o RLS pois é SECURITY DEFINER
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.perfis_usuarios WHERE id = auth.uid();
$$;

-- PASSO 4: Habilitar RLS
ALTER TABLE public.perfis_usuarios ENABLE ROW LEVEL SECURITY;

-- PASSO 5: Policies simples SEM recursão
-- 5a. Usuário vê/edita o próprio perfil
CREATE POLICY "self_select"
ON public.perfis_usuarios FOR SELECT
USING (id = auth.uid());

CREATE POLICY "self_update"
ON public.perfis_usuarios FOR UPDATE
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

CREATE POLICY "self_insert"
ON public.perfis_usuarios FOR INSERT
WITH CHECK (id = auth.uid());

CREATE POLICY "self_delete"
ON public.perfis_usuarios FOR DELETE
USING (id = auth.uid());

-- 5b. Service role (trigger de cadastro) pode inserir
-- O trigger handle_new_user roda como SECURITY DEFINER, então bypassa RLS.
-- Mas para segurança, adicionamos policy de insert aberta (com check no user.id)

-- PASSO 6: Admin acessa qualquer perfil via função SECURITY DEFINER que não tem RLS
-- Criamos uma função auxiliar que lê role SEM acionar RLS
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.perfis_usuarios WHERE id = auth.uid();
$$;

-- Policy admin usando current_user_role() (SECURITY DEFINER = sem RLS loop)
CREATE POLICY "admin_select_all"
ON public.perfis_usuarios FOR SELECT
USING (public.current_user_role() = 'admin');

CREATE POLICY "admin_update_all"
ON public.perfis_usuarios FOR UPDATE
USING (public.current_user_role() = 'admin')
WITH CHECK (public.current_user_role() = 'admin');

-- PASSO 7: Verificar políticas criadas
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'perfis_usuarios';

SELECT '✅ RLS corrigido sem recursão!' AS resultado;
