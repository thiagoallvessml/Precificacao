-- ============================================================
-- FIX DEFINITIVO: infinite recursion in perfis_usuarios
-- 
-- CAUSA: policies que fazem subquery em perfis_usuarios
-- dentro das próprias policies de perfis_usuarios → loop infinito
--
-- SOLUÇÃO: policies de perfis_usuarios usam APENAS auth.uid()
-- diretamente, sem subquery na mesma tabela.
-- Acesso admin é feito exclusivamente via RPC com SECURITY DEFINER.
--
-- Execute no Supabase SQL Editor
-- ============================================================

-- PASSO 1: Remover TODAS as policies atuais de perfis_usuarios
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN
        SELECT policyname FROM pg_policies WHERE tablename = 'perfis_usuarios'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.perfis_usuarios', pol.policyname);
    END LOOP;
END $$;

-- PASSO 2: Recriar policies SIMPLES (sem subquery em perfis_usuarios)

-- Usuário vê e edita apenas o próprio perfil
CREATE POLICY "user_select_own"
    ON public.perfis_usuarios FOR SELECT
    USING (id = auth.uid());

CREATE POLICY "user_update_own"
    ON public.perfis_usuarios FOR UPDATE
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- Sistema pode inserir (trigger de new user)
CREATE POLICY "allow_insert"
    ON public.perfis_usuarios FOR INSERT
    WITH CHECK (true);

-- PASSO 3: Garantir que get_my_role() existe (cria se não existir)
-- Essa função usa SECURITY DEFINER então bypassa RLS ao ser chamada
-- por outras tabelas (page_views, feedbacks, etc) — mas NUNCA
-- deve ser usada dentro de policies de perfis_usuarios!
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.perfis_usuarios WHERE id = auth.uid();
$$;

GRANT EXECUTE ON FUNCTION public.get_my_role() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_my_role() TO anon;

-- PASSO 4: Verificar resultado
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'perfis_usuarios'
ORDER BY cmd;

-- PASSO 5: Testar (deve retornar o role sem erro)
SELECT public.get_my_role() AS meu_role;

SELECT '✅ Recursão corrigida! Policies de perfis_usuarios simplificadas.' AS resultado;
