-- ============================================================
-- VERIFICAR SE HÁ INSUMOS CADASTRADOS
-- ============================================================

-- Ver quantos insumos existem
SELECT COUNT(*) as total_insumos FROM insumos;

-- Ver todos os insumos cadastrados
SELECT id, nome, tipo, unidade_medida, estoque_atual, custo_unitario, ativo 
FROM insumos 
ORDER BY nome;

-- Se não houver insumos, aqui está um exemplo para inserir:
-- INSERT INTO insumos (nome, tipo, unidade_medida, estoque_atual, estoque_minimo, estoque_maximo, custo_unitario) 
-- VALUES ('Leite', 'ingrediente', 'L', 0, 5, 20, 4.50);
