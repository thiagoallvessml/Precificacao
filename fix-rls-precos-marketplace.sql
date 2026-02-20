-- ============================================================
-- SOLUÇÃO: Configurar RLS para precos_marketplace
-- ============================================================
-- Execute este script se a tabela existir mas não estiver
-- retornando dados devido a políticas RLS
-- ============================================================

-- 1. Habilitar RLS
ALTER TABLE precos_marketplace ENABLE ROW LEVEL SECURITY;

-- 2. Dropar políticas antigas (se existirem)
DROP POLICY IF EXISTS "Permitir leitura pública de precos_marketplace" ON precos_marketplace;
DROP POLICY IF EXISTS "Permitir inserção pública de precos_marketplace" ON precos_marketplace;
DROP POLICY IF EXISTS "Permitir atualização pública de precos_marketplace" ON precos_marketplace;
DROP POLICY IF EXISTS "Permitir exclusão pública de precos_marketplace" ON precos_marketplace;

-- 3. Criar políticas públicas (para desenvolvimento/teste)
-- ATENÇÃO: Em produção, ajuste as políticas conforme necessário!

-- Permitir SELECT (leitura)
CREATE POLICY "Permitir leitura pública de precos_marketplace"
ON precos_marketplace
FOR SELECT
USING (true);

-- Permitir INSERT (inserção)
CREATE POLICY "Permitir inserção pública de precos_marketplace"
ON precos_marketplace
FOR INSERT
WITH CHECK (true);

-- Permitir UPDATE (atualização)
CREATE POLICY "Permitir atualização pública de precos_marketplace"
ON precos_marketplace
FOR UPDATE
USING (true)
WITH CHECK (true);

-- Permitir DELETE (exclusão)
CREATE POLICY "Permitir exclusão pública de precos_marketplace"
ON precos_marketplace
FOR DELETE
USING (true);

-- 4. Verificar políticas criadas
SELECT 
    policyname,
    permissive,
    cmd
FROM pg_policies
WHERE tablename = 'precos_marketplace';

-- ✅ Pronto! Agora a tabela deve estar acessível publicamente
