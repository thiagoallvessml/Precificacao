-- ============================================================
-- FIX: column perfis_usuarios.indicacao_origem does not exist
-- Execute no Supabase SQL Editor
-- ============================================================

-- Adicionar coluna indicacao_origem (cupom/código que o usuário usou ao se cadastrar)
ALTER TABLE public.perfis_usuarios
    ADD COLUMN IF NOT EXISTS indicacao_origem TEXT DEFAULT NULL;

-- Verificar
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'perfis_usuarios'
  AND column_name = 'indicacao_origem';

SELECT '✅ Coluna indicacao_origem adicionada com sucesso!' AS resultado;
