-- ============================================================
-- MIGRAÇÃO: Regras de ganho individuais por afiliado
-- Execute este SQL no Supabase SQL Editor
-- ============================================================

-- 1. Adicionar colunas de regras de ganho na perfis_usuarios
ALTER TABLE perfis_usuarios
ADD COLUMN IF NOT EXISTS comissao_recorrente BOOLEAN DEFAULT true;

ALTER TABLE perfis_usuarios
ADD COLUMN IF NOT EXISTS somente_primeira_venda BOOLEAN DEFAULT false;

-- 2. Definir valores padrão para afiliados existentes
UPDATE perfis_usuarios
SET comissao_recorrente = true,
    somente_primeira_venda = false
WHERE role = 'afiliado'
  AND comissao_recorrente IS NULL;

-- 3. Verificar resultado
SELECT id, nome, email, role, nivel_afiliado, comissao_recorrente, somente_primeira_venda
FROM perfis_usuarios
WHERE role = 'afiliado';

SELECT '✅ Colunas comissao_recorrente e somente_primeira_venda adicionadas!' AS resultado;
