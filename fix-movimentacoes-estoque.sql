-- ============================================================
-- Setup: movimentacoes_estoque + RLS de producoes
-- Execute no Supabase SQL Editor
-- ============================================================

-- PASSO 1: Criar tabela movimentacoes_estoque (se não existir)
CREATE TABLE IF NOT EXISTS public.movimentacoes_estoque (
    id                 BIGSERIAL PRIMARY KEY,
    user_id            UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    insumo_id          BIGINT REFERENCES public.insumos(id) ON DELETE CASCADE,
    tipo               TEXT NOT NULL CHECK (tipo IN ('entrada', 'saida', 'ajuste')),
    quantidade         NUMERIC(12,3) NOT NULL,
    estoque_anterior   NUMERIC(12,3),
    estoque_posterior  NUMERIC(12,3),
    motivo             TEXT,
    custo_unitario     NUMERIC(12,4),
    data_movimentacao  DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at         TIMESTAMPTZ DEFAULT NOW()
);

-- PASSO 2: RLS em movimentacoes_estoque
ALTER TABLE public.movimentacoes_estoque ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_all_movimentacoes" ON public.movimentacoes_estoque;
CREATE POLICY "user_all_movimentacoes"
    ON public.movimentacoes_estoque
    FOR ALL
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- PASSO 3: RLS em producoes (fix INSERT bloqueado)
ALTER TABLE public.producoes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_insert_producoes" ON public.producoes;
DROP POLICY IF EXISTS "user_select_producoes" ON public.producoes;
DROP POLICY IF EXISTS "user_update_producoes" ON public.producoes;
DROP POLICY IF EXISTS "user_delete_producoes"  ON public.producoes;

CREATE POLICY "user_insert_producoes"
    ON public.producoes FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_select_producoes"
    ON public.producoes FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "user_update_producoes"
    ON public.producoes FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_delete_producoes"
    ON public.producoes FOR DELETE
    USING (user_id = auth.uid());

-- PASSO 4: Trigger para popular user_id automaticamente nas movimentações
CREATE OR REPLACE FUNCTION public.set_user_id_movimentacoes()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    NEW.user_id := auth.uid();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_user_id_movimentacoes ON public.movimentacoes_estoque;
CREATE TRIGGER trg_set_user_id_movimentacoes
    BEFORE INSERT ON public.movimentacoes_estoque
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id_movimentacoes();

SELECT '✅ movimentacoes_estoque e RLS de producoes configurados!' AS resultado;
