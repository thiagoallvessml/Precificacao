-- ============================================================
-- MIGRAÇÃO: Faturamento via Afiliados
-- Execute este SQL no Supabase SQL Editor
-- ============================================================

-- 1. Adicionar user_id ao cupons_afiliado (para vincular ao afiliado)
ALTER TABLE cupons_afiliado
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Índice para buscar cupons por user_id
CREATE INDEX IF NOT EXISTS idx_cupons_afiliado_user_id ON cupons_afiliado(user_id);

-- 2. Adicionar coluna de data_pagamento se não existir (para tracking de comissões pagas)
-- (já existe na tabela indicacoes conforme schema original)

-- 3. View materializada para relatório de faturamento por afiliado
-- Pode ser usada opcionalmente para performance
CREATE OR REPLACE VIEW vw_faturamento_afiliados AS
SELECT
    ca.user_id,
    ca.id AS cupom_id,
    ca.codigo AS cupom_codigo,
    ca.comissao_percentual,
    COUNT(i.id) AS total_indicacoes,
    COUNT(CASE WHEN i.status = 'ativo' THEN 1 END) AS indicacoes_ativas,
    COUNT(CASE WHEN i.status = 'pendente' THEN 1 END) AS indicacoes_pendentes,
    COALESCE(SUM(CASE WHEN i.status = 'ativo' THEN i.valor_assinatura ELSE 0 END), 0) AS faturamento_total,
    COALESCE(SUM(CASE WHEN i.status = 'ativo' THEN i.valor_comissao ELSE 0 END), 0) AS comissoes_total,
    COALESCE(SUM(CASE WHEN i.comissao_paga = true THEN i.valor_comissao ELSE 0 END), 0) AS comissoes_pagas,
    COALESCE(SUM(CASE WHEN i.comissao_paga = false AND i.status = 'ativo' THEN i.valor_comissao ELSE 0 END), 0) AS comissoes_pendentes
FROM cupons_afiliado ca
LEFT JOIN indicacoes i ON i.cupom_id = ca.id
WHERE ca.ativo = true
GROUP BY ca.id, ca.user_id, ca.codigo, ca.comissao_percentual;

-- Permitir acesso público na view (mesmo padrão do projeto)
GRANT SELECT ON vw_faturamento_afiliados TO anon, authenticated;

-- ============================================================
-- FIM DA MIGRAÇÃO
-- ============================================================
