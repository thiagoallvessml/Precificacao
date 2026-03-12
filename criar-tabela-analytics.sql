-- ============================================================
-- TABELA DE ANALYTICS - Page Views
-- ============================================================
-- Execute este SQL no Supabase SQL Editor

CREATE TABLE IF NOT EXISTS page_views (
    id          BIGSERIAL PRIMARY KEY,
    page        TEXT NOT NULL,                  -- ex: 'combos.html'
    user_id     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    session_id  TEXT,                           -- UUID gerado no browser por sessão
    referrer    TEXT,                           -- página anterior
    user_agent  TEXT,                           -- browser/dispositivo
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_page_views_created_at ON page_views(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_page_views_page       ON page_views(page);
CREATE INDEX IF NOT EXISTS idx_page_views_user_id    ON page_views(user_id);

-- RLS: qualquer usuário autenticado pode inserir sua própria view
ALTER TABLE page_views ENABLE ROW LEVEL SECURITY;

CREATE POLICY "insert_own_view" ON page_views
    FOR INSERT
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Admin pode ler tudo (via service role ou policy de admin)
CREATE POLICY "admin_read_all" ON page_views
    FOR SELECT
    USING (true);  -- O frontend já protege por auth-guard

-- ============================================================
-- VIEW AUXILIAR: resumo diário de views por página
-- ============================================================
CREATE OR REPLACE VIEW vw_page_views_daily AS
SELECT
    DATE(created_at AT TIME ZONE 'America/Sao_Paulo') AS dia,
    page,
    COUNT(*)                                           AS total_views,
    COUNT(DISTINCT session_id)                         AS sessoes_unicas,
    COUNT(DISTINCT user_id)                            AS usuarios_unicos
FROM page_views
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC;
