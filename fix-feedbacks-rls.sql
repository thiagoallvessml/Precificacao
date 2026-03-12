-- ============================================================
-- FIX: RLS bloqueando insert em feedbacks (erro 42501)
-- Execute no Supabase SQL Editor
-- ============================================================

-- Ver policies atuais
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'feedbacks'
ORDER BY cmd;

-- Garantir que a tabela tem RLS habilitado
ALTER TABLE public.feedbacks ENABLE ROW LEVEL SECURITY;

-- Remover policies existentes de INSERT para recriar corretamente
DROP POLICY IF EXISTS "insert_feedbacks" ON public.feedbacks;
DROP POLICY IF EXISTS "users_insert_feedbacks" ON public.feedbacks;
DROP POLICY IF EXISTS "allow_insert_feedbacks" ON public.feedbacks;

-- Qualquer usuário autenticado pode enviar feedback
CREATE POLICY "insert_feedbacks"
    ON public.feedbacks FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Admin pode ver todos os feedbacks
DROP POLICY IF EXISTS "admin_select_feedbacks" ON public.feedbacks;
CREATE POLICY "admin_select_feedbacks"
    ON public.feedbacks FOR SELECT
    USING (public.get_my_role() = 'admin');

-- Usuário pode ver seus próprios feedbacks
DROP POLICY IF EXISTS "user_select_own_feedbacks" ON public.feedbacks;
CREATE POLICY "user_select_own_feedbacks"
    ON public.feedbacks FOR SELECT
    USING (user_id = auth.uid());

SELECT '✅ Policies de feedbacks corrigidas!' AS resultado;
