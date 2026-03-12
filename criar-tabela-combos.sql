-- ============================================================
-- TABELAS DE COMBOS
-- Execute no SQL Editor do Supabase
-- ============================================================

-- Tabela principal de combos
CREATE TABLE IF NOT EXISTS combos (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    imagem_url TEXT,
    preco_venda NUMERIC(10,2) NOT NULL DEFAULT 0,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de itens do combo (produtos e quantidades)
CREATE TABLE IF NOT EXISTS combo_itens (
    id BIGSERIAL PRIMARY KEY,
    combo_id BIGINT REFERENCES combos(id) ON DELETE CASCADE,
    produto_id BIGINT REFERENCES produtos(id) ON DELETE CASCADE,
    quantidade INTEGER NOT NULL DEFAULT 1,
    preco_unitario_snapshot NUMERIC(10,5),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS (Row Level Security)
ALTER TABLE combos ENABLE ROW LEVEL SECURITY;
ALTER TABLE combo_itens ENABLE ROW LEVEL SECURITY;

-- Políticas para combos
CREATE POLICY "Users can view own combos"
    ON combos FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own combos"
    ON combos FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own combos"
    ON combos FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own combos"
    ON combos FOR DELETE USING (auth.uid() = user_id);

-- Políticas para combo_itens (acesso via combo do usuário)
CREATE POLICY "Users can view own combo items"
    ON combo_itens FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM combos WHERE combos.id = combo_itens.combo_id AND combos.user_id = auth.uid()
    ));

CREATE POLICY "Users can insert own combo items"
    ON combo_itens FOR INSERT
    WITH CHECK (EXISTS (
        SELECT 1 FROM combos WHERE combos.id = combo_itens.combo_id AND combos.user_id = auth.uid()
    ));

CREATE POLICY "Users can update own combo items"
    ON combo_itens FOR UPDATE
    USING (EXISTS (
        SELECT 1 FROM combos WHERE combos.id = combo_itens.combo_id AND combos.user_id = auth.uid()
    ));

CREATE POLICY "Users can delete own combo items"
    ON combo_itens FOR DELETE
    USING (EXISTS (
        SELECT 1 FROM combos WHERE combos.id = combo_itens.combo_id AND combos.user_id = auth.uid()
    ));
