-- ============================================================
-- Adicionar coluna 'plano' na tabela perfis_usuarios
-- Execute no Supabase SQL Editor
-- ============================================================

-- 1. Adicionar coluna plano (free por padrão)
ALTER TABLE perfis_usuarios 
ADD COLUMN IF NOT EXISTS plano TEXT NOT NULL DEFAULT 'free'
CHECK (plano IN ('free', 'premium'));

-- 2. Adicionar coluna de data de início do premium (para controle)
ALTER TABLE perfis_usuarios 
ADD COLUMN IF NOT EXISTS premium_inicio TIMESTAMPTZ DEFAULT NULL;

-- 3. Todos os usuários existentes ficam como 'free'
UPDATE perfis_usuarios SET plano = 'free' WHERE plano IS NULL;

-- 4. Verificar
SELECT id, nome, email, role, plano, premium_inicio, created_at 
FROM perfis_usuarios 
ORDER BY created_at DESC;

SELECT '✅ Coluna plano adicionada com sucesso!' AS resultado;
