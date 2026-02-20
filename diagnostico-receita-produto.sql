-- Diagnóstico: Verificar vínculo entre a Receita "Ninho" e Produtos

-- 1. Buscar a receita "Ninho"
SELECT id, nome, descricao 
FROM receitas 
WHERE nome ILIKE '%ninho%';

-- 2. Verificar se existe produto vinculado a essa receita
SELECT 
    p.id as produto_id,
    p.nome as produto_nome,
    p.preco_base,
    p.receita_id,
    r.nome as receita_nome
FROM produtos p
LEFT JOIN receitas r ON r.id = p.receita_id
WHERE r.nome ILIKE '%ninho%';

-- 3. Listar TODOS os produtos e suas receitas
SELECT 
    p.id,
    p.nome as produto,
    p.preco_base,
    r.nome as receita
FROM produtos p
LEFT JOIN receitas r ON r.id = p.receita_id
ORDER BY p.id;

-- 4. Se não houver produto vinculado, veja todos os produtos sem receita
SELECT 
    id,
    nome,
    preco_base,
    receita_id
FROM produtos
WHERE receita_id IS NULL;
