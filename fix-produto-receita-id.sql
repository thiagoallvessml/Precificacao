-- ============================================================
-- VINCULAR PRODUTOS ÀS RECEITAS PELO NOME
-- Execute este SQL no Supabase SQL Editor
-- 
-- Este script preenche o campo receita_id dos produtos
-- que têm o mesmo nome que uma receita cadastrada.
-- Isso garante que o estoque funcione corretamente.
-- ============================================================

-- 1. Verificar situação atual (antes de corrigir)
SELECT 
    p.id AS produto_id,
    p.nome AS produto_nome,
    p.receita_id AS receita_id_atual,
    r.id AS receita_encontrada_id,
    r.nome AS receita_nome
FROM produtos p
LEFT JOIN receitas r ON LOWER(TRIM(r.nome)) = LOWER(TRIM(p.nome))
ORDER BY p.nome;

-- ============================================================
-- 2. ATUALIZAR: preencher receita_id nos produtos pelo nome
-- ============================================================
UPDATE produtos p
SET receita_id = r.id
FROM receitas r
WHERE LOWER(TRIM(r.nome)) = LOWER(TRIM(p.nome))
  AND p.receita_id IS NULL;

-- 3. Confirmar resultado (após corrigir)
SELECT 
    p.id,
    p.nome,
    p.receita_id,
    r.nome AS nome_receita_vinculada
FROM produtos p
LEFT JOIN receitas r ON r.id = p.receita_id
ORDER BY p.nome;

SELECT '✅ Produtos vinculados às receitas pelo nome!' AS resultado;
