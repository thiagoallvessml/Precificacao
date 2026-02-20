-- ============================================================
-- ATUALIZAR PRECISÃO DO CUSTO UNITÁRIO PARA 3 CASAS DECIMAIS
-- ============================================================
-- Este script altera a coluna custo_unitario de DECIMAL(10,2) 
-- para DECIMAL(10,3) para permitir valores como 0.028
-- ============================================================

-- 1. Alterar a coluna custo_unitario na tabela insumos
ALTER TABLE insumos 
ALTER COLUMN custo_unitario TYPE DECIMAL(10,3);

-- 2. Alterar a coluna custo_unitario na tabela movimentacoes_estoque (se existir)
ALTER TABLE movimentacoes_estoque 
ALTER COLUMN custo_unitario TYPE DECIMAL(10,3);

-- 3. Verificar as alterações
SELECT 
    table_name,
    column_name,
    data_type,
    numeric_precision,
    numeric_scale
FROM information_schema.columns
WHERE table_name IN ('insumos', 'movimentacoes_estoque')
    AND column_name = 'custo_unitario';

-- Resultado esperado:
-- custo_unitario deve aparecer como DECIMAL com precision=10 e scale=3
