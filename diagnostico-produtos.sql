-- Diagnóstico: Verificar vínculo entre Receitas e Produtos

-- 1. Listar Receitas e seus Produtos vinculados (se houver)
SELECT 
    r.id as receita_id,
    r.nome as receita_nome,
    p.id as produto_id,
    p.nome as produto_nome,
    p.preco_base
FROM receitas r
LEFT JOIN produtos p ON p.receita_id = r.id;

-- 2. Listar Receitas SEM produtos
SELECT 
    r.id as receita_id,
    r.nome as receita_nome
FROM receitas r
LEFT JOIN produtos p ON p.receita_id = r.id
WHERE p.id IS NULL;

-- 3. Listar Produtos com preço base zerado
SELECT 
    id, 
    nome, 
    preco_base 
FROM produtos 
WHERE preco_base = 0 OR preco_base IS NULL;
