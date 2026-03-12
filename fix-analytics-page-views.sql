-- ============================================================
-- FIX: Analytics sem dados — diagnosticar e corrigir
-- Execute no Supabase SQL Editor
-- ============================================================

-- PASSO 1: Verificar se a tabela page_views existe
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'page_views'
) AS tabela_existe;

-- PASSO 2: Se existir, contar registros
SELECT COUNT(*) AS total_views FROM public.page_views;

-- PASSO 3: Ver policies RLS da tabela
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'page_views'
ORDER BY cmd;

-- ============================================================
-- CORREÇÃO A: Criar tabela page_views caso não exista
-- ============================================================
CREATE TABLE IF NOT EXISTS public.page_views (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    page TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    session_id TEXT,
    referrer TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_page_views_created_at ON public.page_views(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_page_views_user_id ON public.page_views(user_id);
CREATE INDEX IF NOT EXISTS idx_page_views_page ON public.page_views(page);

-- ============================================================
-- CORREÇÃO B: Habilitar RLS e criar policies corretas
-- ============================================================
ALTER TABLE public.page_views ENABLE ROW LEVEL SECURITY;

-- Remover policies existentes para recriar
DROP POLICY IF EXISTS "insert_page_views" ON public.page_views;
DROP POLICY IF EXISTS "admin_select_page_views" ON public.page_views;
DROP POLICY IF EXISTS "select_page_views" ON public.page_views;
DROP POLICY IF EXISTS "anon_insert_page_views" ON public.page_views;

-- Qualquer um pode registrar uma view (inclusive anônimos)
CREATE POLICY "insert_page_views"
    ON public.page_views FOR INSERT
    WITH CHECK (true);

-- Admin pode ver todas as views
CREATE POLICY "admin_select_page_views"
    ON public.page_views FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.perfis_usuarios
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Usuários veem apenas as suas próprias views
CREATE POLICY "user_select_own_page_views"
    ON public.page_views FOR SELECT
    USING (user_id = auth.uid());

-- Permitir insert anônimo (sem autenticação)
ALTER TABLE public.page_views FORCE ROW LEVEL SECURITY;

GRANT INSERT ON public.page_views TO anon;
GRANT INSERT ON public.page_views TO authenticated;
GRANT SELECT ON public.page_views TO authenticated;

-- ============================================================
-- CORREÇÃO C: Criar RPC para admin buscar todas as views (bypassa RLS)
-- ============================================================
CREATE OR REPLACE FUNCTION admin_listar_page_views(
    p_desde TIMESTAMPTZ DEFAULT NOW() - INTERVAL '30 days'
)
RETURNS SETOF page_views
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Verificar se é admin
    IF NOT EXISTS (
        SELECT 1 FROM perfis_usuarios
        WHERE id = auth.uid() AND role = 'admin'
    ) THEN
        RAISE EXCEPTION 'Acesso negado';
    END IF;

    RETURN QUERY
        SELECT * FROM page_views
        WHERE created_at >= p_desde
        ORDER BY created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_listar_page_views(TIMESTAMPTZ) TO authenticated;

-- Verificar resultado final
SELECT 
    (SELECT COUNT(*) FROM page_views) AS total_views,
    (SELECT COUNT(*) FROM page_views WHERE created_at >= NOW() - INTERVAL '30 days') AS views_30_dias,
    '✅ Correções aplicadas com sucesso!' AS status;
