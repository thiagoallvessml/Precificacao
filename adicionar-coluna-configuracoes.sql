-- ============================================================
-- Adicionar coluna 'configuracoes' na tabela perfis_usuarios
-- Execute este script no Supabase SQL Editor
-- ============================================================

-- Adicionar coluna configuracoes como JSONB
ALTER TABLE perfis_usuarios 
ADD COLUMN IF NOT EXISTS configuracoes JSONB DEFAULT NULL;

-- Estrutura esperada do JSON:
-- {
--   "moeda": "BRL",
--   "regiao": "São Paulo - SP",
--   "formato_numero": "pt-BR"
-- }

SELECT '✅ Coluna configuracoes adicionada com sucesso!' AS resultado;
