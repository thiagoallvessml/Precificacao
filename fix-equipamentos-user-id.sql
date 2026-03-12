-- ============================================================
-- MIGRAÇÃO: Adaptar tabela equipamentos para o sistema atual
-- Execute no Supabase SQL Editor
-- ============================================================

-- 1. Adicionar colunas que estão faltando na tabela equipamentos
ALTER TABLE public.equipamentos
    ADD COLUMN IF NOT EXISTS user_id          UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS tipo_equipamento TEXT DEFAULT 'manual' 
        CHECK (tipo_equipamento IN ('eletrico', 'gas', 'manual')),
    ADD COLUMN IF NOT EXISTS potencia_watts   INTEGER,
    ADD COLUMN IF NOT EXISTS custo_hora       DECIMAL(10,6) DEFAULT 0,
    ADD COLUMN IF NOT EXISTS ativo            BOOLEAN DEFAULT true,
    ADD COLUMN IF NOT EXISTS unidade_medida   TEXT DEFAULT 'hora';

-- 2. Índices
CREATE INDEX IF NOT EXISTS idx_equipamentos_user_id ON public.equipamentos(user_id);
CREATE INDEX IF NOT EXISTS idx_equipamentos_ativo   ON public.equipamentos(ativo);

-- 3. Trigger para auto-preencher user_id
CREATE OR REPLACE FUNCTION auto_set_user_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_id IS NULL THEN
        NEW.user_id = auth.uid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS auto_user_id ON public.equipamentos;
CREATE TRIGGER auto_user_id
    BEFORE INSERT ON public.equipamentos
    FOR EACH ROW EXECUTE FUNCTION auto_set_user_id();

-- 4. Habilitar RLS
ALTER TABLE public.equipamentos ENABLE ROW LEVEL SECURITY;

-- 5. Remover policies antigas se existirem
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON public.equipamentos;
DROP POLICY IF EXISTS "user_select_equipamentos"  ON public.equipamentos;
DROP POLICY IF EXISTS "user_insert_equipamentos"  ON public.equipamentos;
DROP POLICY IF EXISTS "user_update_equipamentos"  ON public.equipamentos;
DROP POLICY IF EXISTS "user_delete_equipamentos"  ON public.equipamentos;

-- 6. Criar policies por usuário
CREATE POLICY "user_select_equipamentos"
    ON public.equipamentos FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "user_insert_equipamentos"
    ON public.equipamentos FOR INSERT
    WITH CHECK (user_id = auth.uid() OR user_id IS NULL);

CREATE POLICY "user_update_equipamentos"
    ON public.equipamentos FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_delete_equipamentos"
    ON public.equipamentos FOR DELETE
    USING (user_id = auth.uid());

-- 7. Verificar estrutura final
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'equipamentos'
ORDER BY ordinal_position;

-- 8. Ver policies criadas
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'equipamentos';

SELECT '✅ Tabela equipamentos migrada com sucesso!' AS resultado;
