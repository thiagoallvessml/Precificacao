-- ============================================================
-- TABELAS PARA O PROGRAMA "INDIQUE E GANHE"
-- Execute este SQL no Supabase SQL Editor
-- ============================================================

-- ==============
-- 1. CUPONS DE AFILIADO
-- ==============

CREATE TABLE IF NOT EXISTS cupons_afiliado (
    id BIGSERIAL PRIMARY KEY,
    codigo TEXT NOT NULL UNIQUE,
    desconto_percentual DECIMAL(5,2) DEFAULT 10.00,  -- Desconto que o indicado recebe (%)
    comissao_percentual DECIMAL(5,2) DEFAULT 10.00,   -- Comissão que o afiliado recebe (%)
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE cupons_afiliado IS 'Cupons de desconto para o programa de indicação';
COMMENT ON COLUMN cupons_afiliado.desconto_percentual IS 'Percentual de desconto para quem usa o cupom';
COMMENT ON COLUMN cupons_afiliado.comissao_percentual IS 'Percentual de comissão para o dono do cupom';

-- Índices
CREATE INDEX IF NOT EXISTS idx_cupons_afiliado_codigo ON cupons_afiliado(codigo);
CREATE INDEX IF NOT EXISTS idx_cupons_afiliado_ativo ON cupons_afiliado(ativo);

-- ==============
-- 2. INDICAÇÕES (Referrals)
-- ==============

CREATE TABLE IF NOT EXISTS indicacoes (
    id BIGSERIAL PRIMARY KEY,
    cupom_id BIGINT NOT NULL REFERENCES cupons_afiliado(id) ON DELETE CASCADE,
    nome_indicado TEXT NOT NULL,
    email_indicado TEXT,
    telefone_indicado TEXT,
    status TEXT NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente', 'ativo', 'cancelado', 'expirado')),
    valor_assinatura DECIMAL(10,2) DEFAULT 0,       -- Valor da assinatura contratada
    valor_comissao DECIMAL(10,2) DEFAULT 0,          -- Valor da comissão gerada
    valor_desconto DECIMAL(10,2) DEFAULT 0,          -- Valor do desconto dado ao indicado
    data_indicacao TIMESTAMPTZ DEFAULT NOW(),
    data_conversao TIMESTAMPTZ,                       -- Quando o indicado assinou
    data_pagamento_comissao TIMESTAMPTZ,             -- Quando a comissão foi paga
    comissao_paga BOOLEAN DEFAULT false,
    observacoes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE indicacoes IS 'Registros de indicações do programa Indique e Ganhe';
COMMENT ON COLUMN indicacoes.status IS 'Status da indicação: pendente, ativo, cancelado ou expirado';
COMMENT ON COLUMN indicacoes.valor_comissao IS 'Comissão calculada para o afiliado';

-- Índices
CREATE INDEX IF NOT EXISTS idx_indicacoes_cupom ON indicacoes(cupom_id);
CREATE INDEX IF NOT EXISTS idx_indicacoes_status ON indicacoes(status);
CREATE INDEX IF NOT EXISTS idx_indicacoes_data ON indicacoes(data_indicacao);

-- Triggers de updated_at (drop first to avoid "already exists" error)
DROP TRIGGER IF EXISTS update_cupons_afiliado_updated_at ON cupons_afiliado;
CREATE TRIGGER update_cupons_afiliado_updated_at BEFORE UPDATE ON cupons_afiliado FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
DROP TRIGGER IF EXISTS update_indicacoes_updated_at ON indicacoes;
CREATE TRIGGER update_indicacoes_updated_at BEFORE UPDATE ON indicacoes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

ALTER TABLE cupons_afiliado ENABLE ROW LEVEL SECURITY;
ALTER TABLE indicacoes ENABLE ROW LEVEL SECURITY;

-- Políticas de acesso público (mesmo padrão do projeto)
CREATE POLICY "Permitir acesso publico cupons" ON cupons_afiliado FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir acesso publico indicacoes" ON indicacoes FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- DADOS INICIAIS - Cupom padrão
-- ============================================================

INSERT INTO cupons_afiliado (codigo, desconto_percentual, comissao_percentual)
VALUES ('CARLOS10', 10.00, 10.00)
ON CONFLICT (codigo) DO NOTHING;
