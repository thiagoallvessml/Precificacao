-- ============================================================
-- DIAGNÓSTICO COMPLETO: Preços Marketplace
-- ============================================================
-- Execute este script para verificar toda a estrutura
-- ============================================================

-- 1. Verificar se a tabela existe
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_name = 'precos_marketplace'
) AS tabela_existe;

-- 2. Ver estrutura da tabela
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'precos_marketplace'
ORDER BY ordinal_position;

-- 3. Ver foreign keys
SELECT
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'precos_marketplace'
    AND tc.constraint_type = 'FOREIGN KEY';

-- 4. Contar registros
SELECT COUNT(*) as total_precos FROM precos_marketplace;

-- 5. Ver produtos disponíveis
SELECT 
    id,
    nome,
    preco_base,
    disponivel
FROM produtos
WHERE disponivel = true
ORDER BY id;

-- 6. Ver categorias marketplace
SELECT 
    id,
    nome,
    tipo,
    ativo
FROM categorias
WHERE tipo = 'marketplace'
ORDER BY id;

-- 7. Ver preços existentes (se houver)
SELECT 
    pm.id,
    pm.produto_id,
    p.nome as produto_nome,
    pm.categoria_marketplace_id,
    c.nome as marketplace_nome,
    pm.preco,
    pm.ativo
FROM precos_marketplace pm
LEFT JOIN produtos p ON pm.produto_id = p.id
LEFT JOIN categorias c ON pm.categoria_marketplace_id = c.id
ORDER BY pm.produto_id, pm.categoria_marketplace_id;

-- 8. Verificar permissões RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename = 'precos_marketplace';

-- 9. Ver políticas RLS
SELECT 
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'precos_marketplace';
