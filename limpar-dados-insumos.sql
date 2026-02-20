-- ============================================================
-- LIMPAR TODOS OS DADOS DE INSUMOS E MOVIMENTAÇÕES
-- ============================================================
-- Execute este script no Supabase SQL Editor para resetar os dados
-- ============================================================

-- 1. Deletar todas as movimentações de estoque
DELETE FROM movimentacoes_estoque;

-- 2. Deletar todos os insumos
DELETE FROM insumos;

-- 3. OPCIONAL: Se quiser resetar o contador de IDs (autoincrement)
-- Descomente as linhas abaixo se quiser que os próximos IDs comecem do 1
-- ALTER SEQUENCE movimentacoes_estoque_id_seq RESTART WITH 1;
-- ALTER SEQUENCE insumos_id_seq RESTART WITH 1;

-- ============================================================
-- CONFIRMAÇÃO
-- ============================================================
SELECT 
    'Dados limpos com sucesso!' as status,
    (SELECT COUNT(*) FROM insumos) as total_insumos,
    (SELECT COUNT(*) FROM movimentacoes_estoque) as total_movimentacoes;
