-- ============================================================
-- DIAGNÓSTICO DIRETO: Ver se o nome bate entre producoes e produtos
-- Execute no Supabase SQL Editor
-- ============================================================

-- 1. Ver produtos (id, nome, receita_id)
SELECT id, nome, receita_id, disponivel FROM produtos ORDER BY nome;

-- ============================================================

-- 2. Comparação direta: nome da producao vs nome do produto
-- Mostra se o matching vai funcionar
SELECT 
    pr.id AS producao_id,
    pr.nome_receita,
    pr.receita_id AS prod_receita_id,
    pr.total_unidades,
    p.id AS produto_id,
    p.nome AS produto_nome,
    p.receita_id AS produto_receita_id,
    LOWER(TRIM(pr.nome_receita)) = LOWER(TRIM(p.nome)) AS nome_bate
FROM producoes pr
CROSS JOIN produtos p
ORDER BY pr.id, p.id;

-- ============================================================

-- 3. FIX DEFINITIVO: Atualiza receita_id dos produtos pelo nome
-- (Se nome_bate = true acima, isso vai resolver o estoque)
UPDATE produtos p
SET receita_id = pr.receita_id
FROM producoes pr
WHERE LOWER(TRIM(pr.nome_receita)) = LOWER(TRIM(p.nome))
  AND p.receita_id IS NULL;

-- Confirmar
SELECT id, nome, receita_id FROM produtos;

SELECT '✅ FIX aplicado!' AS resultado;
