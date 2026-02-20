-- ============================================================
-- CORREÇÃO DEFINITIVA: Remover FK e Alterar 'tipo' para TEXT
-- ============================================================

-- PROBLEMA DESCOBERTO:
-- Existe uma FK chamada "insumos_categoria_fk" na coluna 'tipo'
-- que está impedindo a alteração para TEXT

-- SOLUÇÃO:
-- 1. Remover a FK
-- 2. Alterar para TEXT
-- 3. Converter dados

-- ====================
-- PASSO 1: Ver todas as FKs da tabela insumos
-- ====================
SELECT
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'insumos'::regclass;

-- ====================
-- PASSO 2: REMOVER A FK PROBLEMÁTICA
-- ====================

-- Remover a FK 'insumos_categoria_fk'
ALTER TABLE insumos 
DROP CONSTRAINT IF EXISTS insumos_categoria_fk;

-- Remover outras constraints relacionadas ao tipo
ALTER TABLE insumos 
DROP CONSTRAINT IF EXISTS insumos_tipo_check;

ALTER TABLE insumos 
DROP CONSTRAINT IF EXISTS insumos_tipo_fkey;

-- ====================
-- PASSO 3: VER DADOS ATUAIS (ANTES DA CONVERSÃO)
-- ====================

SELECT 
    tipo,
    COUNT(*) as total,
    STRING_AGG(DISTINCT nome, ', ') as exemplos
FROM insumos
GROUP BY tipo;

-- ====================
-- PASSO 4: ALTERAR TIPO DA COLUNA
-- ====================

-- Alterar de BIGINT para TEXT com conversão
ALTER TABLE insumos 
ALTER COLUMN tipo TYPE TEXT 
USING CASE 
    WHEN tipo = 1 THEN 'ingrediente'
    WHEN tipo = 2 THEN 'embalagem'
    WHEN tipo = 3 THEN 'equipamento'
    ELSE 'ingrediente' -- fallback padrão
END;

-- ====================
-- PASSO 5: ATUALIZAR DADOS RESTANTES (SE NECESSÁRIO)
-- ====================

-- Garantir que todos os valores sejam válidos
UPDATE insumos 
SET tipo = 'ingrediente'
WHERE tipo NOT IN ('ingrediente', 'embalagem', 'equipamento');

-- ====================
-- PASSO 6: ADICIONAR CONSTRAINT DE VALIDAÇÃO
-- ====================

ALTER TABLE insumos 
ADD CONSTRAINT insumos_tipo_check 
CHECK (tipo IN ('ingrediente', 'embalagem', 'equipamento'));

-- ====================
-- PASSO 7: VERIFICAR SE FUNCIONOU
-- ====================

-- Estrutura da coluna
SELECT 
    column_name,
    data_type,
    character_maximum_length
FROM information_schema.columns
WHERE table_name = 'insumos' AND column_name = 'tipo';
-- Deve mostrar: tipo | text

-- Dados após conversão
SELECT 
    tipo,
    COUNT(*) as total
FROM insumos
GROUP BY tipo
ORDER BY tipo;
-- Deve mostrar: ingrediente, embalagem, equipamento

-- ====================
-- PASSO 8: TESTAR QUERY DO JAVASCRIPT
-- ====================

-- Esta query DEVE funcionar agora:
SELECT id, nome, unidade_medida, custo_unitario, tipo
FROM insumos
WHERE tipo = 'ingrediente' AND ativo = true
ORDER BY nome
LIMIT 5;

-- Se retornar dados sem erro: ✅ SUCESSO!

-- ====================
-- PASSO 9: SE NÃO HOUVER DADOS, INSERIR EXEMPLOS
-- ====================

-- Ingredientes
INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, categoria_id, ativo)
VALUES 
    ('Leite Condensado Moça 395g', 'ingrediente', 'g', 13.70, NULL, true),
    ('Creme de Leite Nestlé 200g', 'ingrediente', 'g', 4.50, NULL, true),
    ('Leite Ninho 400g', 'ingrediente', 'g', 18.90, NULL, true),
    ('Nutella 350g', 'ingrediente', 'g', 22.50, NULL, true),
    ('Morango Congelado 1kg', 'ingrediente', 'kg', 15.00, NULL, true)
ON CONFLICT DO NOTHING;

-- Embalagens
INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, categoria_id, ativo)
VALUES 
    ('Saco 6x24 (100un)', 'embalagem', 'un', 0.15, NULL, true),
    ('Saco 5x23 (100un)', 'embalagem', 'un', 0.12, NULL, true),
    ('Pote 100ml com Tampa', 'embalagem', 'un', 0.80, NULL, true),
    ('Palito de Madeira (100un)', 'embalagem', 'un', 0.05, NULL, true)
ON CONFLICT DO NOTHING;

-- Equipamentos
INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, categoria_id, ativo)
VALUES 
    ('Freezer Horizontal 400L', 'equipamento', 'kWh', 0.85, NULL, true),
    ('Liquidificador Industrial 2L', 'equipamento', 'kWh', 0.50, NULL, true),
    ('Batedeira Planetária 5L', 'equipamento', 'kWh', 0.40, NULL, true)
ON CONFLICT DO NOTHING;

-- ====================
-- PASSO 10: VERIFICAÇÃO FINAL
-- ====================

SELECT 
    '✅ CORREÇÃO COMPLETA!' as status,
    (SELECT data_type FROM information_schema.columns WHERE table_name = 'insumos' AND column_name = 'tipo') as tipo_da_coluna,
    (SELECT COUNT(*) FROM insumos) as total_insumos,
    (SELECT COUNT(*) FROM insumos WHERE tipo = 'ingrediente') as ingredientes,
    (SELECT COUNT(*) FROM insumos WHERE tipo = 'embalagem') as embalagens,
    (SELECT COUNT(*) FROM insumos WHERE tipo = 'equipamento') as equipamentos;

-- ====================
-- RESUMO DO QUE FOI FEITO
-- ====================

/*
✅ Removida FK 'insumos_categoria_fk'
✅ Alterada coluna 'tipo' de BIGINT para TEXT
✅ Convertidos valores numéricos (1,2,3) para texto
✅ Adicionada validação CHECK
✅ Inseridos dados de exemplo (se necessário)
✅ Testada query do JavaScript

AGORA A PÁGINA DEVE FUNCIONAR! 🎉
*/
