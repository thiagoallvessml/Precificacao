-- ============================================================
-- Suporte a cancelamento com acesso até fim do período
-- Execute no Supabase SQL Editor
-- ============================================================

-- 1. Coluna para marcar que o cancelamento foi solicitado
ALTER TABLE perfis_usuarios
ADD COLUMN IF NOT EXISTS cancelamento_agendado BOOLEAN NOT NULL DEFAULT FALSE;

-- 2. Coluna para guardar a data de expiração do acesso após cancelamento
ALTER TABLE perfis_usuarios
ADD COLUMN IF NOT EXISTS premium_expira_em TIMESTAMPTZ DEFAULT NULL;

-- 3. Verificar estrutura
SELECT id, nome, plano, premium_inicio, premium_expira_em, cancelamento_agendado
FROM perfis_usuarios
ORDER BY created_at DESC
LIMIT 10;

SELECT '✅ Colunas de cancelamento adicionadas com sucesso!' AS resultado;
