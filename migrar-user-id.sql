-- ============================================================
-- MIGRAÇÃO: ISOLAMENTO DE DADOS POR USUÁRIO
-- ============================================================
-- EXECUTE ESTE SCRIPT NO SQL EDITOR DO SUPABASE
-- 
-- O que este script faz:
-- 1. Adiciona coluna user_id em todas as tabelas principais
-- 2. Cria trigger para auto-preencher user_id (sem alterar frontend)
-- 3. Remove políticas RLS antigas (acesso público)
-- 4. Cria políticas novas (cada usuário vê SÓ seus dados)
-- 5. Atribuir dados existentes ao admin
-- ============================================================

-- ====================
-- PASSO 0: Descobrir seu user_id atual
-- ====================
-- EXECUTE PRIMEIRO e anote o ID do seu usuário admin:
SELECT id, email, created_at FROM auth.users ORDER BY created_at ASC LIMIT 10;


-- ====================
-- PASSO 1: ADICIONAR COLUNA user_id EM TODAS AS TABELAS
-- ====================

-- Categorias
ALTER TABLE categorias ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_categorias_user_id ON categorias(user_id);

-- Insumos
ALTER TABLE insumos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_insumos_user_id ON insumos(user_id);

-- Produtos
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_produtos_user_id ON produtos(user_id);

-- Receitas
ALTER TABLE receitas ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_receitas_user_id ON receitas(user_id);

-- Receita Insumos (receitas_insumos)
ALTER TABLE receitas_insumos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_receitas_insumos_user_id ON receitas_insumos(user_id);

-- Pedidos
ALTER TABLE pedidos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_pedidos_user_id ON pedidos(user_id);

-- Pedido Itens
ALTER TABLE pedido_itens ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_pedido_itens_user_id ON pedido_itens(user_id);

-- Produção
ALTER TABLE producao ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_producao_user_id ON producao(user_id);

-- Movimentações Estoque
ALTER TABLE movimentacoes_estoque ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_movimentacoes_user_id ON movimentacoes_estoque(user_id);

-- Despesas
ALTER TABLE despesas ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_despesas_user_id ON despesas(user_id);

-- Equipamentos
ALTER TABLE equipamentos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_equipamentos_user_id ON equipamentos(user_id);

-- Chaves Pix
ALTER TABLE chaves_pix ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_chaves_pix_user_id ON chaves_pix(user_id);

-- Configurações
ALTER TABLE configuracoes ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_configuracoes_user_id ON configuracoes(user_id);

-- Preços Marketplace
ALTER TABLE precos_marketplace ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_precos_marketplace_user_id ON precos_marketplace(user_id);

-- Marketplaces
ALTER TABLE marketplaces ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_marketplaces_user_id ON marketplaces(user_id);


-- ====================
-- PASSO 2: CRIAR TRIGGER PARA AUTO-PREENCHER user_id
-- ====================
-- Com isso, NÃO precisa alterar nenhuma página HTML/JS!
-- O banco preenche user_id = auth.uid() automaticamente ao inserir.

CREATE OR REPLACE FUNCTION auto_set_user_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_id IS NULL THEN
        NEW.user_id = auth.uid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger em TODAS as tabelas
DO $$
DECLARE
    tabelas TEXT[] := ARRAY[
        'categorias', 'insumos', 'produtos', 'receitas',
        'receitas_insumos', 'pedidos', 'pedido_itens',
        'producao', 'movimentacoes_estoque', 'despesas',
        'equipamentos', 'chaves_pix', 'configuracoes',
        'precos_marketplace', 'marketplaces'
    ];
    t TEXT;
BEGIN
    FOREACH t IN ARRAY tabelas
    LOOP
        -- Verificar se a tabela existe antes de criar o trigger
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = t AND table_schema = 'public') THEN
            EXECUTE format('DROP TRIGGER IF EXISTS auto_user_id ON %I', t);
            EXECUTE format('CREATE TRIGGER auto_user_id BEFORE INSERT ON %I FOR EACH ROW EXECUTE FUNCTION auto_set_user_id()', t);
        END IF;
    END LOOP;
END $$;


-- ====================
-- PASSO 3: ATRIBUIR DADOS EXISTENTES AO ADMIN
-- ====================
-- ⚠️ IMPORTANTE: Substitua 'SEU_USER_ID_AQUI' pelo ID do PASSO 0!
-- Exemplo: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
-- Descomente as linhas abaixo e cole o ID correto:

/*
DO $$
DECLARE
    admin_id UUID := 'SEU_USER_ID_AQUI';
BEGIN
    UPDATE categorias SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE insumos SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE produtos SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE receitas SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE receitas_insumos SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE pedidos SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE pedido_itens SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE producao SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE movimentacoes_estoque SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE despesas SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE equipamentos SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE chaves_pix SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE configuracoes SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE precos_marketplace SET user_id = admin_id WHERE user_id IS NULL;
    UPDATE marketplaces SET user_id = admin_id WHERE user_id IS NULL;
    
    RAISE NOTICE '✅ Todos os dados existentes atribuídos ao admin: %', admin_id;
END $$;
*/


-- ====================
-- PASSO 4: REMOVER TODAS AS POLÍTICAS RLS ANTIGAS
-- ====================

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT schemaname, tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
    END LOOP;
    RAISE NOTICE '✅ Todas as políticas RLS antigas removidas';
END $$;


-- ====================
-- PASSO 5: HABILITAR RLS EM TODAS AS TABELAS
-- ====================

ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE insumos ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE receitas ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedido_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE producao ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE despesas ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipamentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE chaves_pix ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE precos_marketplace ENABLE ROW LEVEL SECURITY;
ALTER TABLE marketplaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE perfis_usuarios ENABLE ROW LEVEL SECURITY;

-- Tabelas que podem ter nomes diferentes
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'receitas_insumos' AND table_schema = 'public') THEN
        ALTER TABLE receitas_insumos ENABLE ROW LEVEL SECURITY;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'receita_insumos' AND table_schema = 'public') THEN
        ALTER TABLE receita_insumos ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;


-- ====================
-- PASSO 6: CRIAR POLÍTICAS RLS POR USUÁRIO
-- ====================
-- Cada usuário só vê, insere, edita e deleta SEUS PRÓPRIOS dados

-- Helper: cria 4 políticas (SELECT, INSERT, UPDATE, DELETE) para uma tabela
DO $$
DECLARE
    tabelas TEXT[] := ARRAY[
        'categorias', 'insumos', 'produtos', 'receitas',
        'pedidos', 'pedido_itens', 'producao', 'movimentacoes_estoque',
        'despesas', 'equipamentos', 'chaves_pix', 'configuracoes',
        'precos_marketplace', 'marketplaces'
    ];
    t TEXT;
BEGIN
    FOREACH t IN ARRAY tabelas
    LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = t AND table_schema = 'public') THEN
            -- SELECT: ver só seus dados
            EXECUTE format(
                'CREATE POLICY "user_select_%1$s" ON %1$I FOR SELECT USING (user_id = auth.uid())',
                t
            );
            -- INSERT: inserir só com seu user_id
            EXECUTE format(
                'CREATE POLICY "user_insert_%1$s" ON %1$I FOR INSERT WITH CHECK (user_id = auth.uid())',
                t
            );
            -- UPDATE: editar só seus dados
            EXECUTE format(
                'CREATE POLICY "user_update_%1$s" ON %1$I FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid())',
                t
            );
            -- DELETE: deletar só seus dados
            EXECUTE format(
                'CREATE POLICY "user_delete_%1$s" ON %1$I FOR DELETE USING (user_id = auth.uid())',
                t
            );
        END IF;
    END LOOP;
END $$;

-- Receitas_insumos (pode ter nome com s ou sem)
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'receitas_insumos' AND table_schema = 'public') THEN
        CREATE POLICY "user_select_receitas_insumos" ON receitas_insumos FOR SELECT USING (user_id = auth.uid());
        CREATE POLICY "user_insert_receitas_insumos" ON receitas_insumos FOR INSERT WITH CHECK (user_id = auth.uid());
        CREATE POLICY "user_update_receitas_insumos" ON receitas_insumos FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
        CREATE POLICY "user_delete_receitas_insumos" ON receitas_insumos FOR DELETE USING (user_id = auth.uid());
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'receita_insumos' AND table_schema = 'public') THEN
        CREATE POLICY "user_select_receita_insumos" ON receita_insumos FOR SELECT USING (user_id = auth.uid());
        CREATE POLICY "user_insert_receita_insumos" ON receita_insumos FOR INSERT WITH CHECK (user_id = auth.uid());
        CREATE POLICY "user_update_receita_insumos" ON receita_insumos FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
        CREATE POLICY "user_delete_receita_insumos" ON receita_insumos FOR DELETE USING (user_id = auth.uid());
    END IF;
END $$;

-- Perfis Usuarios: cada um vê só o SEU perfil
CREATE POLICY "user_select_perfil" ON perfis_usuarios FOR SELECT USING (id = auth.uid());
CREATE POLICY "user_update_perfil" ON perfis_usuarios FOR UPDATE USING (id = auth.uid()) WITH CHECK (id = auth.uid());
-- Admin pode ver todos os perfis
CREATE POLICY "admin_select_all_perfis" ON perfis_usuarios FOR SELECT USING (
    EXISTS (SELECT 1 FROM perfis_usuarios WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "admin_update_all_perfis" ON perfis_usuarios FOR UPDATE USING (
    EXISTS (SELECT 1 FROM perfis_usuarios WHERE id = auth.uid() AND role = 'admin')
);
-- INSERT do perfil (feito pelo trigger do cadastro)
CREATE POLICY "user_insert_perfil" ON perfis_usuarios FOR INSERT WITH CHECK (id = auth.uid());


-- ====================
-- PASSO 7: VERIFICAÇÃO FINAL
-- ====================

-- Verificar que as políticas foram criadas
SELECT 
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Verificar que user_id existe nas tabelas
SELECT 
    table_name,
    column_name
FROM information_schema.columns
WHERE column_name = 'user_id'
  AND table_schema = 'public'
ORDER BY table_name;

SELECT '✅ Migração concluída! Cada usuário agora vê apenas seus próprios dados.' AS status;
