-- ============================================================
-- DIAGNÓSTICO COMPLETO - Por que insumos não carregam?
-- ============================================================

-- ====================
-- 1. VERIFICAR SE A TABELA EXISTE
-- ====================

SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'insumos';

-- Deve retornar: insumos | BASE TABLE

-- ====================
-- 2. VERIFICAR ESTRUTURA DA TABELA (COLUNAS)
-- ====================

SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'insumos'
ORDER BY ordinal_position;

-- Deve ter as colunas: id, nome, tipo, unidade_medida, custo_unitario, ativo

-- ====================
-- 3. VERIFICAR SE TEM DADOS
-- ====================

SELECT 
    COUNT(*) as total_insumos,
    COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
    COUNT(CASE WHEN ativo = false THEN 1 END) as inativos
FROM insumos;

-- ====================
-- 4. VERIFICAR DADOS POR TIPO
-- ====================

SELECT 
    tipo,
    COUNT(*) as total,
    COUNT(CASE WHEN ativo = true THEN 1 END) as ativos
FROM insumos
GROUP BY tipo
ORDER BY tipo;

-- ====================
-- 5. VER EXEMPLOS DE CADA TIPO
-- ====================

-- Ingredientes
SELECT id, nome, tipo, unidade_medida, custo_unitario, ativo
FROM insumos
WHERE tipo = 'ingrediente'
LIMIT 5;

-- Embalagens
SELECT id, nome, tipo, unidade_medida, custo_unitario, ativo
FROM insumos
WHERE tipo = 'embalagem'
LIMIT 5;

-- Equipamentos
SELECT id, nome, tipo, unidade_medida, custo_unitario, ativo
FROM insumos
WHERE tipo = 'equipamento'
LIMIT 5;

-- ====================
-- 6. VERIFICAR POLÍTICAS RLS
-- ====================

SELECT 
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'insumos';

-- ====================
-- 7. VERIFICAR SE RLS ESTÁ HABILITADO
-- ====================

SELECT 
    schemaname,
    tablename,
    rowsecurity,
    CASE WHEN rowsecurity THEN 'RLS HABILITADO ✅' ELSE 'RLS DESABILITADO ❌' END as status
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'insumos';

-- ====================
-- 8. TESTAR QUERY EXATA DO JAVASCRIPT
-- ====================

-- Esta é a query que o JavaScript executa:
SELECT id, nome, unidade_medida, custo_unitario, tipo
FROM insumos
WHERE tipo = 'ingrediente' AND ativo = true
ORDER BY nome;

-- Se retornar dados, o problema não é SQL!

-- ====================
-- 9. VERIFICAR TIPO DE DADOS NAS COLUNAS
-- ====================

SELECT 
    tipo,
    nome,
    custo_unitario,
    pg_typeof(custo_unitario) as tipo_custo,
    unidade_medida,
    pg_typeof(unidade_medida) as tipo_unidade,
    ativo,
    pg_typeof(ativo) as tipo_ativo
FROM insumos
LIMIT 3;

-- ====================
-- 10. RESUMO FINAL
-- ====================

SELECT 
    'DIAGNÓSTICO COMPLETO' as titulo,
    (SELECT COUNT(*) FROM insumos) as total_insumos,
    (SELECT COUNT(*) FROM insumos WHERE tipo = 'ingrediente') as ingredientes,
    (SELECT COUNT(*) FROM insumos WHERE tipo = 'embalagem') as embalagens,
    (SELECT COUNT(*) FROM insumos WHERE tipo = 'equipamento') as equipamentos,
    (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'insumos') as politicas_rls,
    (SELECT rowsecurity FROM pg_tables WHERE tablename = 'insumos') as rls_habilitado;
