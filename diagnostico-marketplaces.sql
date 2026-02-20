-- ============================================================
-- DIAGNÓSTICO: Verificar Marketplaces
-- ============================================================
-- Este script verifica quais marketplaces existem e ajuda a
-- identificar o problema de foreign key
-- ============================================================

-- 1. Listar todos os marketplaces ativos
SELECT 
    id,
    nome,
    taxa_operacional,
    categoria_id,
    ativo,
    created_at
FROM marketplaces
ORDER BY id;

-- 2. Verificar se há algum preço com marketplace_id inválido
-- (Esta query irá falhar se houver preços órfãos)
SELECT 
    pm.id,
    pm.produto_id,
    pm.marketplace_id,
    pm.preco,
    m.nome as marketplace_nome
FROM precos_marketplace pm
LEFT JOIN marketplaces m ON pm.marketplace_id = m.id
WHERE m.id IS NULL;

-- 3. Contar marketplaces por status
SELECT 
    ativo,
    COUNT(*) as total
FROM marketplaces
GROUP BY ativo;

-- 4. Verificar categorias de marketplace
SELECT 
    c.id,
    c.nome,
    c.tipo
FROM categorias c
WHERE c.tipo = 'marketplace'
ORDER BY c.id;
