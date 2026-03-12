-- ============================================================
-- FIX: RLS bloqueando INSERT em saques_afiliado (erro 42501)
-- Execute no Supabase SQL Editor
-- ============================================================

-- Ver policies atuais
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'saques_afiliado'
ORDER BY cmd;

-- Habilitar RLS (caso não esteja)
ALTER TABLE public.saques_afiliado ENABLE ROW LEVEL SECURITY;

-- Remover policies existentes para recriar
DROP POLICY IF EXISTS "insert_saques_afiliado" ON public.saques_afiliado;
DROP POLICY IF EXISTS "user_insert_saques" ON public.saques_afiliado;
DROP POLICY IF EXISTS "allow_insert_saques" ON public.saques_afiliado;
DROP POLICY IF EXISTS "select_saques_afiliado" ON public.saques_afiliado;
DROP POLICY IF EXISTS "user_select_saques" ON public.saques_afiliado;
DROP POLICY IF EXISTS "admin_select_saques" ON public.saques_afiliado;
DROP POLICY IF EXISTS "admin_update_saques" ON public.saques_afiliado;

-- Usuário autenticado pode solicitar saque (inserir o próprio)
CREATE POLICY "user_insert_saques"
    ON public.saques_afiliado FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- Usuário vê apenas os próprios saques
CREATE POLICY "user_select_saques"
    ON public.saques_afiliado FOR SELECT
    USING (user_id = auth.uid() OR public.get_my_role() = 'admin');

-- Admin pode atualizar status do saque (aprovar/recusar)
CREATE POLICY "admin_update_saques"
    ON public.saques_afiliado FOR UPDATE
    USING (public.get_my_role() = 'admin')
    WITH CHECK (public.get_my_role() = 'admin');

SELECT '✅ Policies de saques_afiliado corrigidas!' AS resultado;
