-- ============================================================
-- FIX: AJUSTAR UNIQUE CONSTRAINTS PARA MULTI-TENANT
-- ============================================================
-- A tabela configuracoes tinha UNIQUE só em 'chave', 
-- mas agora cada usuário precisa ter suas próprias configs.
-- Este script altera para UNIQUE(chave, user_id).
-- ============================================================

-- 1. Remover a constraint antiga (chave única global)
ALTER TABLE configuracoes DROP CONSTRAINT IF EXISTS configuracoes_chave_key;

-- 2. Criar nova constraint (chave única POR USUÁRIO)
ALTER TABLE configuracoes ADD CONSTRAINT configuracoes_chave_user_id_key UNIQUE (chave, user_id);

-- 3. Fazer o mesmo para chaves_pix (se tiver o mesmo problema)
ALTER TABLE chaves_pix DROP CONSTRAINT IF EXISTS chaves_pix_chave_key;

-- Verificar
SELECT '✅ Constraint atualizada! Agora cada usuário pode ter suas próprias configurações.' AS status;
