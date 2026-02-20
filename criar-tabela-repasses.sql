-- ============================================================
-- TABELA: repasses_afiliado (Histórico de Pagamentos a Afiliados)
-- Execute este SQL no Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS repasses_afiliado (
    id BIGSERIAL PRIMARY KEY,
    cupom_id BIGINT REFERENCES cupons_afiliado(id) ON DELETE SET NULL,
    nome_afiliado TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL DEFAULT 0,
    chave_pix TEXT,
    qtd_indicacoes INTEGER DEFAULT 0,
    observacoes TEXT,
    data_repasse TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE repasses_afiliado IS 'Histórico de repasses financeiros realizados para afiliados';
COMMENT ON COLUMN repasses_afiliado.valor IS 'Valor total do repasse em reais';
COMMENT ON COLUMN repasses_afiliado.qtd_indicacoes IS 'Quantidade de indicações incluídas neste repasse';

-- Índices
CREATE INDEX IF NOT EXISTS idx_repasses_afiliado_cupom ON repasses_afiliado(cupom_id);
CREATE INDEX IF NOT EXISTS idx_repasses_afiliado_data ON repasses_afiliado(data_repasse);

-- RLS
ALTER TABLE repasses_afiliado ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permitir acesso publico repasses" ON repasses_afiliado FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- Adicionar coluna chave_pix na tabela perfis_usuarios (se não existir)
-- Para que afiliados possam cadastrar sua chave Pix no perfil
-- ============================================================

ALTER TABLE perfis_usuarios ADD COLUMN IF NOT EXISTS chave_pix TEXT;

-- ============================================================
-- FIM
-- ============================================================
