-- ============================================================
-- INSERIR PREÇOS DE TESTE
-- ============================================================
-- Este script insere preços de exemplo para testar o sistema
-- IMPORTANTE: Ajuste os IDs conforme seu banco de dados!
-- ============================================================

-- PASSO 1: Ver seus produtos e marketplaces
-- Execute primeiro para anotar os IDs corretos:

SELECT 'PRODUTOS DISPONÍVEIS:' as info;
SELECT id, nome, preco_base FROM produtos WHERE disponivel = true ORDER BY id;

SELECT 'MARKETPLACES (CATEGORIAS):' as info;
SELECT id, nome FROM categorias WHERE tipo = 'marketplace' AND ativo = true ORDER BY id;

-- ============================================================
-- PASSO 2: Anote os IDs e ajuste o INSERT abaixo
-- ============================================================

-- Exemplo: Se você tem
-- Produto ID 1 = "Ninho com Nutella"
-- Produto ID 2 = "Geladinho Morango"
-- Marketplace ID 16 = "iFood"
-- Marketplace ID 17 = "WhatsApp"

-- Então ajuste assim:
INSERT INTO precos_marketplace (
    produto_id, 
    categoria_marketplace_id, 
    preco, 
    margem_lucro,
    ativo
) VALUES 
    -- Ninho com Nutella
    (1, 16, 12.50, NULL, true),  -- iFood
    (1, 17, 10.00, NULL, true),  -- WhatsApp
    
    -- Geladinho Morango  
    (2, 16, 8.00, NULL, true),   -- iFood
    (2, 17, 7.00, NULL, true)    -- WhatsApp

ON CONFLICT (produto_id, categoria_marketplace_id) 
DO UPDATE SET 
    preco = EXCLUDED.preco,
    ativo = EXCLUDED.ativo,
    updated_at = NOW();

-- ============================================================
-- PASSO 3: Verificar preços inseridos
-- ============================================================

SELECT 
    pm.id,
    p.nome as produto,
    c.nome as marketplace,
    pm.preco,
    pm.ativo
FROM precos_marketplace pm
JOIN produtos p ON pm.produto_id = p.id
JOIN categorias c ON pm.categoria_marketplace_id = c.id
ORDER BY p.nome, c.nome;

-- ✅ Agora recarregue vendas.html e veja os preços aparecerem!
