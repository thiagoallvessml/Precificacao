-- ============================================================
-- CORRIGIR RLS DA TABELA PEDIDOS
-- ============================================================
-- O problema é que pedidoData está retornando null
-- Isso acontece quando RLS bloqueia o SELECT após INSERT
-- ============================================================

-- 1. Ver políticas atuais
SELECT 
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'pedidos';

-- 2. Habilitar RLS
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;

-- 3. Dropar políticas antigas
DROP POLICY IF EXISTS "Permitir leitura pública de pedidos" ON pedidos;
DROP POLICY IF EXISTS "Permitir inserção pública de pedidos" ON pedidos;
DROP POLICY IF EXISTS "Permitir atualização pública de pedidos" ON pedidos;
DROP POLICY IF EXISTS "Permitir exclusão pública de pedidos" ON pedidos;

-- 4. Criar políticas públicas (DESENVOLVIMENTO)
CREATE POLICY "Permitir leitura pública de pedidos"
ON pedidos FOR SELECT USING (true);

CREATE POLICY "Permitir inserção pública de pedidos"
ON pedidos FOR INSERT WITH CHECK (true);

CREATE POLICY "Permitir atualização pública de pedidos"
ON pedidos FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Permitir exclusão pública de pedidos"
ON pedidos FOR DELETE USING (true);

-- 5. Fazer o mesmo para pedido_itens
ALTER TABLE pedido_itens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Permitir leitura pública de pedido_itens" ON pedido_itens;
DROP POLICY IF EXISTS "Permitir inserção pública de pedido_itens" ON pedido_itens;
DROP POLICY IF EXISTS "Permitir atualização pública de pedido_itens" ON pedido_itens;
DROP POLICY IF EXISTS "Permitir exclusão pública de pedido_itens" ON pedido_itens;

CREATE POLICY "Permitir leitura pública de pedido_itens"
ON pedido_itens FOR SELECT USING (true);

CREATE POLICY "Permitir inserção pública de pedido_itens"
ON pedido_itens FOR INSERT WITH CHECK (true);

CREATE POLICY "Permitir atualização pública de pedido_itens"
ON pedido_itens FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Permitir exclusão pública de pedido_itens"
ON pedido_itens FOR DELETE USING (true);

-- 6. Verificar políticas criadas
SELECT 
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename IN ('pedidos', 'pedido_itens')
ORDER BY tablename, policyname;

-- ✅ PRONTO! Agora o INSERT deve retornar o registro inserido
