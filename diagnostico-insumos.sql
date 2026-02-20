-- ============================================================
-- DIAGNÓSTICO: Insumos não aparecem em Adicionar Receita
-- ============================================================

-- ====================
-- 1. VERIFICAR SE TEM INSUMOS CADASTRADOS
-- ====================

-- Ver todos os insumos agrupados por tipo
SELECT 
    tipo,
    COUNT(*) as total,
    COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
    COUNT(CASE WHEN ativo = false THEN 1 END) as inativos
FROM insumos
GROUP BY tipo
ORDER BY tipo;

-- Resultado esperado:
-- tipo         | total | ativos | inativos
-- -------------|-------|--------|----------
-- ingrediente  | 10    | 8      | 2
-- embalagem    | 5     | 5      | 0
-- equipamento  | 3     | 3      | 0

-- ====================
-- 2. VER DETALHES DOS INSUMOS POR TIPO
-- ====================

-- Ingredientes
SELECT id, nome, tipo, unidade_medida, custo_unitario, ativo
FROM insumos
WHERE tipo = 'ingrediente'
ORDER BY nome;

-- Embalagens
SELECT id, nome, tipo, unidade_medida, custo_unitario, ativo
FROM insumos
WHERE tipo = 'embalagem'
ORDER BY nome;

-- Equipamentos
SELECT id, nome, tipo, unidade_medida, custo_unitario, ativo
FROM insumos
WHERE tipo = 'equipamento'
ORDER BY nome;

-- ====================
-- 3. VERIFICAR PROBLEMAS COMUNS
-- ====================

-- Insumos sem tipo definido (NULL)
SELECT id, nome, tipo, ativo
FROM insumos
WHERE tipo IS NULL;

-- Insumos com tipo inválido
SELECT id, nome, tipo, ativo
FROM insumos
WHERE tipo NOT IN ('ingrediente', 'embalagem', 'equipamento');

-- Insumos inativos (não aparecem)
SELECT tipo, COUNT(*) as total_inativos
FROM insumos
WHERE ativo = false
GROUP BY tipo;

-- Insumos sem custo unitário (podem causar erro)
SELECT id, nome, tipo, custo_unitario
FROM insumos
WHERE custo_unitario IS NULL OR custo_unitario = 0;

-- ====================
-- 4. CORRIGIR PROBLEMAS
-- ====================

-- Se houver insumos sem tipo, defina um tipo:
-- UPDATE insumos SET tipo = 'ingrediente' WHERE id = X AND tipo IS NULL;

-- Se houver insumos inativos que devem estar ativos:
-- UPDATE insumos SET ativo = true WHERE id = X;

-- Se houver insumos sem custo:
-- UPDATE insumos SET custo_unitario = 10.00 WHERE id = X;

-- ====================
-- 5. INSERIR INSUMOS DE EXEMPLO (SE NÃO HOUVER)
-- ====================

-- Ingredientes de exemplo
INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, ativo)
VALUES 
    ('Leite Condensado Moça 395g', 'ingrediente', 'g', 13.70, true),
    ('Creme de Leite Nestlé 200g', 'ingrediente', 'g', 4.50, true),
    ('Leite Ninho 400g', 'ingrediente', 'g', 18.90, true),
    ('Nutella 350g', 'ingrediente', 'g', 22.50, true),
    ('Morango Congelado 1kg', 'ingrediente', 'kg', 15.00, true),
    ('Açúcar 1kg', 'ingrediente', 'kg', 4.50, true),
    ('Chocolate em Pó 200g', 'ingrediente', 'g', 8.90, true)
ON CONFLICT (nome) DO NOTHING;

-- Embalagens de exemplo
INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, ativo)
VALUES 
    ('Saco 6x24 (100un)', 'embalagem', 'un', 0.15, true),
    ('Saco 5x23 (100un)', 'embalagem', 'un', 0.12, true),
    ('Pote 100ml com Tampa', 'embalagem', 'un', 0.80, true),
    ('Palito de Madeira (100un)', 'embalagem', 'un', 0.05, true),
    ('Etiqueta Adesiva (100un)', 'embalagem', 'un', 0.10, true)
ON CONFLICT (nome) DO NOTHING;

-- Equipamentos de exemplo
INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, ativo)
VALUES 
    ('Freezer Horizontal 400L', 'equipamento', 'kWh', 0.85, true),
    ('Liquidificador Industrial 2L', 'equipamento', 'kWh', 0.50, true),
    ('Batedeira Planetária 5L', 'equipamento', 'kWh', 0.40, true)
ON CONFLICT (nome) DO NOTHING;

-- ====================
-- 6. VERIFICAÇÃO FINAL
-- ====================

-- Este SELECT deve retornar pelo menos 1 linha de cada tipo
SELECT 
    tipo,
    COUNT(*) as total_cadastrados,
    STRING_AGG(nome, ', ' ORDER BY nome) as exemplos
FROM insumos
WHERE ativo = true
GROUP BY tipo
ORDER BY tipo;

-- ====================
-- 7. TESTAR PERMISSÕES RLS
-- ====================

-- Verificar políticas de acesso à tabela insumos
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'insumos';

-- Se não houver política pública, criar:
-- CREATE POLICY "Permitir acesso público" ON insumos FOR ALL USING (true);

-- ====================
-- RESUMO DO DIAGNÓSTICO
-- ====================

-- ✅ Checklist:
-- [ ] Existem insumos cadastrados?
-- [ ] Os insumos têm tipo correto? ('ingrediente', 'embalagem', 'equipamento')
-- [ ] Os insumos estão ativos? (ativo = true)
-- [ ] Os insumos têm custo_unitario > 0?
-- [ ] Há política RLS permitindo acesso?

SELECT 
    '✅ Diagnóstico completo!' as status,
    CASE 
        WHEN (SELECT COUNT(*) FROM insumos WHERE tipo = 'ingrediente' AND ativo = true) > 0 
        THEN '✅ Tem ingredientes'
        ELSE '❌ SEM INGREDIENTES'
    END as ingredientes,
    CASE 
        WHEN (SELECT COUNT(*) FROM insumos WHERE tipo = 'embalagem' AND ativo = true) > 0 
        THEN '✅ Tem embalagens'
        ELSE '❌ SEM EMBALAGENS'
    END as embalagens,
    CASE 
        WHEN (SELECT COUNT(*) FROM insumos WHERE tipo = 'equipamento' AND ativo = true) > 0 
        THEN '✅ Tem equipamentos'
        ELSE '❌ SEM EQUIPAMENTOS'
    END as equipamentos;
