-- ============================================================
-- CORREÇÃO DE TABELAS E PERMISSÕES - RECEITAS
-- ============================================================
-- Execute este script no SQL Editor do Supabase para corrigir 
-- o erro "Could not find the table 'public.receitas_insumos'"
-- ============================================================

-- 1. Cria a tabela 'receitas' se não existir
CREATE TABLE IF NOT EXISTS receitas (
    id BIGSERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    descricao TEXT,
    rendimento_unidades INTEGER NOT NULL,
    tempo_preparo INTEGER,
    custo_mao_obra DECIMAL(10,2) DEFAULT 0,
    instrucoes TEXT,
    imagem_url TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Cria a tabela 'receitas_insumos' (no plural) se não existir
-- Nota: A tabela foi ajustada para corresponder ao que o front-end envia
CREATE TABLE IF NOT EXISTS receitas_insumos (
    id BIGSERIAL PRIMARY KEY,
    receita_id BIGINT NOT NULL REFERENCES receitas(id) ON DELETE CASCADE,
    insumo_id BIGINT NOT NULL REFERENCES insumos(id) ON DELETE CASCADE,
    quantidade DECIMAL(10,3) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(receita_id, insumo_id)
);

-- 3. Habilita RLS (Row Level Security)
ALTER TABLE receitas ENABLE ROW LEVEL SECURITY;
ALTER TABLE receitas_insumos ENABLE ROW LEVEL SECURITY;

-- 4. Cria políticas de acesso público (para evitar erros de permissão)
DROP POLICY IF EXISTS "Permitir acesso total a receitas" ON receitas;
CREATE POLICY "Permitir acesso total a receitas" ON receitas FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Permitir acesso total a receitas_insumos" ON receitas_insumos;
CREATE POLICY "Permitir acesso total a receitas_insumos" ON receitas_insumos FOR ALL USING (true) WITH CHECK (true);

-- 5. Verifica se a tabela 'receita_insumos' (singular) existe e avisa
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'receita_insumos') THEN
        RAISE NOTICE 'A tabela antiga receita_insumos (singular) existe. Considere migrar os dados e removê-la.';
    END IF;
END $$;
