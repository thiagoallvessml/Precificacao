-- ============================================================
-- MIGRAÇÃO: Adicionar nível de afiliado
-- Execute este SQL no Supabase SQL Editor
-- ============================================================

-- 1. Adicionar coluna nivel_afiliado à tabela perfis_usuarios
ALTER TABLE perfis_usuarios
ADD COLUMN IF NOT EXISTS nivel_afiliado TEXT DEFAULT 'bronze'
CHECK (nivel_afiliado IN ('bronze', 'prata', 'ouro'));

-- 2. Definir todos os afiliados existentes como bronze por padrão
UPDATE perfis_usuarios
SET nivel_afiliado = 'bronze'
WHERE role = 'afiliado' AND nivel_afiliado IS NULL;

-- 3. Verificar resultado
SELECT id, nome, email, role, nivel_afiliado
FROM perfis_usuarios
WHERE role = 'afiliado';
