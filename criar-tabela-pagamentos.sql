-- Migração: Adicionar colunas de controle de plano/pagamento
-- Execute no SQL Editor do Supabase

-- 1. Adicionar colunas ao perfis_usuarios (se ainda não existirem)
ALTER TABLE perfis_usuarios
    ADD COLUMN IF NOT EXISTS plano_expires_at     TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS ultimo_pagamento_id  TEXT,
    ADD COLUMN IF NOT EXISTS ultimo_pagamento_em  TIMESTAMPTZ;

-- 2. Criar tabela de histórico de pagamentos (opcional mas recomendado)
CREATE TABLE IF NOT EXISTS pagamentos (
    id              BIGSERIAL PRIMARY KEY,
    user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    billing_id      TEXT,
    plano           TEXT,
    status          TEXT DEFAULT 'pendente',   -- pago | pendente | cancelado
    valor           NUMERIC(10, 2),
    metodo          TEXT DEFAULT 'pix',
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Habilitar RLS na tabela pagamentos
ALTER TABLE pagamentos ENABLE ROW LEVEL SECURITY;

-- 4. Policy: usuário vê apenas seus pagamentos
CREATE POLICY "pagamentos_select_own"
    ON pagamentos FOR SELECT
    USING (auth.uid() = user_id);

-- 5. Policy: apenas service_role pode inserir (webhook usa service_role key)
CREATE POLICY "pagamentos_insert_service"
    ON pagamentos FOR INSERT
    WITH CHECK (true);  -- Protegido pela service_role key no webhook

-- 6. Index para buscas rápidas por user_id
CREATE INDEX IF NOT EXISTS idx_pagamentos_user_id ON pagamentos(user_id);
CREATE INDEX IF NOT EXISTS idx_pagamentos_billing_id ON pagamentos(billing_id);
