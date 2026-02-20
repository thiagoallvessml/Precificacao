-- ============================================================
-- PRODUTOS DE EXEMPLO
-- ============================================================
-- Este script insere produtos de exemplo para testar
-- a página de gestão de produtos
-- ============================================================

-- IMPORTANTE: Primeiro, vamos buscar os IDs das categorias de produtos
-- Execute esta query primeiro para ver os IDs:
-- SELECT id, nome FROM categorias WHERE tipo = 'produtos';

-- ============================================================
-- OPÇÃO 1: Inserir produtos com IDs conhecidos
-- ============================================================
-- Ajuste os categoria_id conforme seus IDs reais!

INSERT INTO produtos (nome, descricao, categoria_id, preco_base, disponivel, destaque)
VALUES 
    -- Produtos Cremosos (assumindo categoria_id = 1)
    ('Ninho com Morango', 'Delicioso geladinho de leite ninho com morango fresco', 1, 6.00, true, true),
    ('Nutella Premium', 'Cremoso geladinho de nutella com pedaços de avelã', 1, 7.50, true, true),
    ('Chocolate Belga', 'Geladinho de chocolate belga premium', 1, 6.50, true, false),
    ('Doce de Leite', 'Tradicional geladinho de doce de leite caseiro', 1, 5.50, true, false),
    
    -- Produtos de Frutas (assumindo categoria_id = 2)
    ('Maracujá Azedinho', 'Refrescante geladinho de maracujá natural', 2, 5.00, true, false),
    ('Morango Natural', 'Geladinho de morango com pedaços da fruta', 2, 5.50, true, true),
    ('Uva Verde', 'Geladinho de uva verde refrescante', 2, 5.00, true, false),
    ('Abacaxi Hortelã', 'Geladinho tropical de abacaxi com toque de hortelã', 2, 5.50, true, false),
    
    -- Produtos Gourmet/Especiais (assumindo categoria_id = 4)
    ('Pistache Premium', 'Geladinho gourmet de pistache importado', 4, 9.00, true, true),
    ('Red Velvet', 'Exclusivo geladinho sabor red velvet', 4, 8.50, true, true),
    ('Limão Siciliano', 'Geladinho sofisticado de limão siciliano', 4, 7.00, true, false);

-- ============================================================
-- OPÇÃO 2: Inserir produtos usando subconsultas (RECOMENDADO)
-- ============================================================
-- Esta opção busca automaticamente os IDs das categorias pelo nome

-- Limpar produtos de exemplo anteriores (opcional)
-- DELETE FROM produtos WHERE nome LIKE '%Premium%' OR nome LIKE '%Azedinho%';

-- Produtos Cremosos
INSERT INTO produtos (nome, descricao, categoria_id, preco_base, disponivel, destaque)
SELECT 
    unnest(ARRAY[
        'Ninho com Morango',
        'Nutella Premium',
        'Chocolate Belga',
        'Doce de Leite'
    ]) as nome,
    unnest(ARRAY[
        'Delicioso geladinho de leite ninho com morango fresco',
        'Cremoso geladinho de nutella com pedaços de avelã',
        'Geladinho de chocolate belga premium',
        'Tradicional geladinho de doce de leite caseiro'
    ]) as descricao,
    c.id as categoria_id,
    unnest(ARRAY[6.00, 7.50, 6.50, 5.50]) as preco_base,
    unnest(ARRAY[true, true, true, true]) as disponivel,
    unnest(ARRAY[true, true, false, false]) as destaque
FROM categorias c
WHERE c.tipo = 'produtos' AND c.nome = 'Cremoso'
LIMIT 4;

-- Produtos de Frutas
INSERT INTO produtos (nome, descricao, categoria_id, preco_base, disponivel, destaque)
SELECT 
    unnest(ARRAY[
        'Maracujá Azedinho',
        'Morango Natural',
        'Uva Verde',
        'Abacaxi Hortelã'
    ]) as nome,
    unnest(ARRAY[
        'Refrescante geladinho de maracujá natural',
        'Geladinho de morango com pedaços da fruta',
        'Geladinho de uva verde refrescante',
        'Geladinho tropical de abacaxi com toque de hortelã'
    ]) as descricao,
    c.id as categoria_id,
    unnest(ARRAY[5.00, 5.50, 5.00, 5.50]) as preco_base,
    unnest(ARRAY[true, true, true, true]) as disponivel,
    unnest(ARRAY[false, true, false, false]) as destaque
FROM categorias c
WHERE c.tipo = 'produtos' AND c.nome = 'Frutas'
LIMIT 4;

-- Produtos Gourmet
INSERT INTO produtos (nome, descricao, categoria_id, preco_base, disponivel, destaque)
SELECT 
    unnest(ARRAY[
        'Pistache Premium',
        'Red Velvet',
        'Limão Siciliano'
    ]) as nome,
    unnest(ARRAY[
        'Geladinho gourmet de pistache importado',
        'Exclusivo geladinho sabor red velvet',
        'Geladinho sofisticado de limão siciliano'
    ]) as descricao,
    c.id as categoria_id,
    unnest(ARRAY[9.00, 8.50, 7.00]) as preco_base,
    unnest(ARRAY[true, true, true]) as disponivel,
    unnest(ARRAY[true, true, false]) as destaque
FROM categorias c
WHERE c.tipo = 'produtos' AND c.nome = 'Gourmet'
LIMIT 3;

-- ============================================================
-- VERIFICAÇÃO
-- ============================================================

-- Ver todos os produtos criados
SELECT 
    p.id,
    p.nome,
    p.preco_base,
    c.nome as categoria,
    p.disponivel,
    p.destaque
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
ORDER BY c.nome, p.nome;

-- Contar produtos por categoria
SELECT 
    c.nome as categoria,
    COUNT(p.id) as total_produtos
FROM categorias c
LEFT JOIN produtos p ON p.categoria_id = c.id
WHERE c.tipo = 'produtos'
GROUP BY c.id, c.nome
ORDER BY c.nome;

-- ============================================================
-- LIMPEZA (caso queira remover os produtos de exemplo)
-- ============================================================

-- CUIDADO! Isso vai deletar TODOS os produtos
-- Descomente apenas se tiver certeza:
-- DELETE FROM produtos;

-- Ou delete apenas produtos específicos:
-- DELETE FROM produtos WHERE nome IN ('Ninho com Morango', 'Nutella Premium', 'Maracujá Azedinho');

-- ============================================================
-- DICAS
-- ============================================================

-- 1. Para adicionar imagens aos produtos:
-- UPDATE produtos 
-- SET imagem_url = 'https://sua-url-da-imagem.com/imagem.jpg'
-- WHERE nome = 'Nome do Produto';

-- 2. Para marcar um produto como indisponível:
-- UPDATE produtos 
-- SET disponivel = false
-- WHERE id = 1;

-- 3. Para destacar um produto:
-- UPDATE produtos 
-- SET destaque = true
-- WHERE id = 1;

-- 4. Para alterar o preço:
-- UPDATE produtos 
-- SET preco_base = 8.00
-- WHERE id = 1;

SELECT 'Produtos de exemplo criados com sucesso!' as status;
