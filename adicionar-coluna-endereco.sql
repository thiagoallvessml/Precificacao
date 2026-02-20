-- ============================================================
-- Adicionar coluna 'endereco' na tabela perfis_usuarios
-- Execute este script no Supabase SQL Editor
-- ============================================================

-- Adicionar coluna endereco como JSONB para armazenar dados estruturados
ALTER TABLE perfis_usuarios 
ADD COLUMN IF NOT EXISTS endereco JSONB DEFAULT NULL;

-- Estrutura esperada do JSON:
-- {
--   "cep": "01001-000",
--   "rua": "Rua das Flores",
--   "numero": "123",
--   "complemento": "Sala 2",
--   "bairro": "Centro",
--   "cidade": "São Paulo",
--   "estado": "SP"
-- }

SELECT '✅ Coluna endereco adicionada com sucesso!' AS resultado;
