-- ============================================================
-- CORREÇÃO RLS: tabelas combos e combo_itens
-- Execute no Supabase → SQL Editor
-- ============================================================

-- ── 1. Garantir coluna user_id em combos ──────────────────────
ALTER TABLE public.combos
    ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_combos_user_id ON public.combos(user_id);

-- ── 2. Trigger para preencher user_id automaticamente ─────────
CREATE OR REPLACE FUNCTION auto_set_user_id_combos()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_id IS NULL THEN
        NEW.user_id = auth.uid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_auto_user_id_combos ON public.combos;
CREATE TRIGGER trg_auto_user_id_combos
    BEFORE INSERT ON public.combos
    FOR EACH ROW EXECUTE FUNCTION auto_set_user_id_combos();

-- ── 3. Habilitar RLS nas duas tabelas ─────────────────────────
ALTER TABLE public.combos      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.combo_itens ENABLE ROW LEVEL SECURITY;

-- ── 4. Remover policies antigas ───────────────────────────────
DROP POLICY IF EXISTS "combos_select"       ON public.combos;
DROP POLICY IF EXISTS "combos_insert"       ON public.combos;
DROP POLICY IF EXISTS "combos_update"       ON public.combos;
DROP POLICY IF EXISTS "combos_delete"       ON public.combos;
DROP POLICY IF EXISTS "combo_itens_select"  ON public.combo_itens;
DROP POLICY IF EXISTS "combo_itens_insert"  ON public.combo_itens;
DROP POLICY IF EXISTS "combo_itens_update"  ON public.combo_itens;
DROP POLICY IF EXISTS "combo_itens_delete"  ON public.combo_itens;

-- ── 5. Policies para combos ───────────────────────────────────
CREATE POLICY "combos_select"
    ON public.combos FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "combos_insert"
    ON public.combos FOR INSERT
    WITH CHECK (user_id = auth.uid() OR user_id IS NULL);

CREATE POLICY "combos_update"
    ON public.combos FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "combos_delete"
    ON public.combos FOR DELETE
    USING (user_id = auth.uid());

-- ── 6. Policies para combo_itens (herda do combo pai) ─────────
CREATE POLICY "combo_itens_select"
    ON public.combo_itens FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.combos c
            WHERE c.id = combo_itens.combo_id
              AND c.user_id = auth.uid()
        )
    );

CREATE POLICY "combo_itens_insert"
    ON public.combo_itens FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.combos c
            WHERE c.id = combo_itens.combo_id
              AND c.user_id = auth.uid()
        )
    );

CREATE POLICY "combo_itens_update"
    ON public.combo_itens FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.combos c
            WHERE c.id = combo_itens.combo_id
              AND c.user_id = auth.uid()
        )
    );

CREATE POLICY "combo_itens_delete"
    ON public.combo_itens FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.combos c
            WHERE c.id = combo_itens.combo_id
              AND c.user_id = auth.uid()
        )
    );

-- ── 7. Verificar ──────────────────────────────────────────────
SELECT policyname, tablename, cmd
FROM pg_policies
WHERE tablename IN ('combos', 'combo_itens')
ORDER BY tablename, cmd;

SELECT '✅ RLS de combos e combo_itens corrigido!' AS resultado;
