-- ============================================================
-- VERIFICAR E INSERIR EMBALAGENS E EQUIPAMENTOS
-- ============================================================

-- ====================
-- 1. VERIFICAR O QUE TEM CADASTRADO
-- ====================

SELECT 
    tipo,
    COUNT(*) as total,
    STRING_AGG(nome, ', ' ORDER BY nome) as nomes
FROM insumos
WHERE ativo = true
GROUP BY tipo
ORDER BY tipo;

-- Deve mostrar quantos de cada tipo existem

-- ====================
-- 2. VER QUAIS TIPOS EXISTEM
-- ====================

SELECT DISTINCT tipo 
FROM insumos 
ORDER BY tipo;

-- ====================
-- 3. INSERIR EMBALAGENS DE EXEMPLO
-- ====================

INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, categoria_id, ativo, estoque_atual)
VALUES 
    ('Saco Plástico 6x24cm (100un)', 'embalagem', 'un', 0.15, NULL, true, 500),
    ('Saco Plástico 5x23cm (100un)', 'embalagem', 'un', 0.12, NULL, true, 300),
    ('Pote 100ml com Tampa', 'embalagem', 'un', 0.80, NULL, true, 200),
    ('Pote 150ml com Tampa', 'embalagem', 'un', 0.95, NULL, true, 150),
    ('Palito de Madeira (pacote 100un)', 'embalagem', 'un', 0.05, NULL, true, 1000),
    ('Colher Descartável (pacote 100un)', 'embalagem', 'un', 0.08, NULL, true, 500),
    ('Canudo (pacote 100un)', 'embalagem', 'un', 0.06, NULL, true, 400),
    ('Etiqueta Adesiva Personalizada (100un)', 'embalagem', 'un', 0.10, NULL, true, 300),
    ('Caixa Térmica Isopor 3L', 'embalagem', 'un', 5.50, NULL, true, 20),
    ('Saco Zip Lock Grande (50un)', 'embalagem', 'un', 0.25, NULL, true, 200)
ON CONFLICT (nome) DO NOTHING;

-- ====================
-- 4. INSERIR EQUIPAMENTOS DE EXEMPLO
-- ====================

INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, categoria_id, ativo, estoque_atual)
VALUES 
    ('Freezer Horizontal 400L', 'equipamento', 'kWh', 0.85, NULL, true, 1),
    ('Freezer Vertical 280L', 'equipamento', 'kWh', 0.65, NULL, true, 1),
    ('Liquidificador Industrial 2L', 'equipamento', 'kWh', 0.50, NULL, true, 2),
    ('Liquidificador Doméstico 1.5L', 'equipamento', 'kWh', 0.30, NULL, true, 1),
    ('Batedeira Planetária 5L', 'equipamento', 'kWh', 0.40, NULL, true, 1),
    ('Mixer de Mão', 'equipamento', 'kWh', 0.20, NULL, true, 2),
    ('Fogão Industrial 4 Bocas', 'equipamento', 'gás', 15.00, NULL, true, 1),
    ('Panela Grande 20L', 'equipamento', 'un', 0.00, NULL, true, 3),
    ('Freezer Expositora Vertical', 'equipamento', 'kWh', 1.20, NULL, true, 1),
    ('Balança Digital 5kg', 'equipamento', 'un', 0.00, NULL, true, 1)
ON CONFLICT (nome) DO NOTHING;

-- ====================
-- 5. VERIFICAR SE INSERIU
-- ====================

-- Contar por tipo
SELECT 
    tipo,
    COUNT(*) as total_cadastrado,
    COUNT(CASE WHEN ativo = true THEN 1 END) as total_ativo
FROM insumos
GROUP BY tipo
ORDER BY tipo;

-- Ver exemplos de cada tipo
SELECT tipo, nome, unidade_medida, custo_unitario
FROM insumos
WHERE tipo = 'embalagem' AND ativo = true
ORDER BY nome
LIMIT 5;

SELECT tipo, nome, unidade_medida, custo_unitario
FROM insumos
WHERE tipo = 'equipamento' AND ativo = true
ORDER BY nome
LIMIT 5;

-- ====================
-- 6. TESTAR QUERIES DO JAVASCRIPT
-- ====================

-- Embalagens
SELECT id, nome, unidade_medida, custo_unitario, tipo
FROM insumos
WHERE tipo = 'embalagem' AND ativo = true
ORDER BY nome;

-- Equipamentos
SELECT id, nome, unidade_medida, custo_unitario, tipo
FROM insumos
WHERE tipo = 'equipamento' AND ativo = true
ORDER BY nome;

-- ====================
-- 7. RESUMO FINAL
-- ====================

SELECT 
    '✅ Dados de exemplo inseridos!' as status,
    (SELECT COUNT(*) FROM insumos WHERE tipo = 'ingrediente' AND ativo = true) as ingredientes,
    (SELECT COUNT(*) FROM insumos WHERE tipo = 'embalagem' AND ativo = true) as embalagens,
    (SELECT COUNT(*) FROM insumos WHERE tipo = 'equipamento' AND ativo = true) as equipamentos;

-- Agora recarregue a página adicionar-receita.html
-- As embalagens e equipamentos devem aparecer nos dropdowns!
