-- ============================================================
-- FIX: Política RLS para cupons_afiliado
-- Permite que qualquer usuário autenticado leia cupons ATIVOS
-- (necessário para o checkout validar cupons de afiliados)
--
-- Como rodar:
-- 1. Acesse: https://supabase.com/dashboard/project/SEU_PROJETO/sql/new
-- 2. Cole este SQL e clique em "Run"
-- ============================================================

-- Remove políticas antigas de SELECT (se existirem) para evitar conflito
DROP POLICY IF EXISTS "cupons ativos são visíveis publicamente" ON cupons_afiliado;
DROP POLICY IF EXISTS "cupons_select_policy" ON cupons_afiliado;
DROP POLICY IF EXISTS "Leitura publica de cupons ativos" ON cupons_afiliado;

-- Garante que RLS está habilitado na tabela
ALTER TABLE cupons_afiliado ENABLE ROW LEVEL SECURITY;

-- Política 1: Qualquer usuário autenticado pode LER cupons ativos
-- (necessário para o checkout validar o cupom digitado pelo comprador)
CREATE POLICY "cupons ativos sao visiveis por usuarios autenticados"
ON cupons_afiliado
FOR SELECT
TO authenticated
USING (ativo = true);

-- Política 2: Dono do cupom pode ver TODOS os seus cupons (ativos ou não)
CREATE POLICY "dono ve todos os seus cupons"
ON cupons_afiliado
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Política 3: Apenas o dono pode INSERIR cupons seus
CREATE POLICY "dono insere seus cupons"
ON cupons_afiliado
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Política 4: Apenas o dono pode ATUALIZAR seus cupons
CREATE POLICY "dono atualiza seus cupons"
ON cupons_afiliado
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Política 5: Apenas o dono pode DELETAR seus cupons
CREATE POLICY "dono deleta seus cupons"
ON cupons_afiliado
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- Verificar políticas criadas
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'cupons_afiliado'
ORDER BY policyname;
