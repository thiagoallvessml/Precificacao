-- Tabela de feedbacks dos usuários (dúvidas e sugestões)
CREATE TABLE IF NOT EXISTS feedbacks (
    id          BIGSERIAL PRIMARY KEY,
    user_id     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    nome        TEXT,
    email       TEXT,
    tipo        TEXT DEFAULT 'sugestao' CHECK (tipo IN ('duvida', 'sugestao', 'bug', 'elogio')),
    mensagem    TEXT NOT NULL,
    status      TEXT DEFAULT 'novo' CHECK (status IN ('novo', 'lido', 'respondido')),
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE feedbacks ENABLE ROW LEVEL SECURITY;

-- Usuários podem inserir seus próprios feedbacks
DROP POLICY IF EXISTS "feedbacks_insert" ON feedbacks;
CREATE POLICY "feedbacks_insert" ON feedbacks
    FOR INSERT WITH CHECK (true);

-- Usuários só veem seus próprios feedbacks
DROP POLICY IF EXISTS "feedbacks_select_own" ON feedbacks;
CREATE POLICY "feedbacks_select_own" ON feedbacks
    FOR SELECT USING (user_id = auth.uid() OR user_id IS NULL);

-- Admin vê tudo (se tiver service_role ou role = admin via RLS separada)
