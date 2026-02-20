-- ============================================================
-- PASSO 1: Ver IDs Reais no Seu Banco
-- ============================================================

-- Ver produtos disponíveis
SELECT 
    'PRODUTOS' as tipo,
    id, 
    nome,
    preco_base
FROM produtos 
WHERE disponivel = true
ORDER BY id;

-- Ver categorias marketplace
SELECT 
    'MARKETPLACES' as tipo,
    id, 
    nome,
    icone
FROM categorias 
WHERE tipo = 'marketplace' AND ativo = true
ORDER BY id;

-- ============================================================
-- PASSO 2: Copie os IDs acima e ajuste o INSERT abaixo
-- ============================================================

-- Exemplo: Se os resultados foram:
-- Produtos:    id=1 (Ninho), id=2 (Morango)
-- Marketplaces: id=5 (iFood), id=6 (WhatsApp)

-- Então o INSERT seria:
/*
INSERT INTO precos_marketplace (produto_id, categoria_marketplace_id, preco, ativo)
VALUES 
    (1, 5, 12.50, true),   -- Ninho no iFood
    (1, 6, 10.00, true),   -- Ninho no WhatsApp
    (2, 5, 8.00, true),    -- Morango no iFood
    (2, 6, 7.00, true);    -- Morango no WhatsApp
*/

-- ============================================================
-- IMPORTANTE: Execute primeiro o SELECT acima para ver os IDs!
-- Depois descomente e ajuste o INSERT com os IDs corretos
-- ============================================================
