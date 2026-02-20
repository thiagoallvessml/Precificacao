-- ============================================================
-- MIGRAÇÃO: ADICIONAR user_id E RLS POR USUÁRIO
-- ============================================================
-- EXECUTE ESTE SCRIPT NO SQL EDITOR DO SUPABASE
-- 
-- O que este script faz:
-- 1. Adiciona coluna user_id em todas as tabelas principais
-- 2. Atualiza registros existentes para o primeiro admin (seu user)
-- 3. Remove políticas RLS antigas (acesso público)
-- 4. Cria políticas novas (cada usuário vê só seus dados)
-- ============================================================

-- ====================
-- PASSO 0: Descobrir seu user_id atual
-- ====================
-- Copie o resultado deste SELECT e cole no PASSO 2
SELECT id, email FROM auth.users ORDER BY created_at ASC LIMIT 5;

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

-- Receita Insumos
ALTER TABLE receita_insumos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_receita_insumos_user_id ON receita_insumos(user_id);

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
-- PASSO 2: ATRIBUIR DADOS EXISTENTES AO SEU USUÁRIO
-- ====================
-- ⚠️ IMPORTANTE: Substitua 'SEU_USER_ID_AQUI' pelo ID do PASSO 0
-- Exemplo: UPDATE categorias SET user_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890' WHERE user_id IS NULL;

-- Descomente e substitua o ID real:
/*
UPDATE categorias SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE insumos SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE produtos SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE receitas SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE receita_insumos SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE pedidos SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE pedido_itens SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE producao SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE movimentacoes_estoque SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE despesas SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE equipamentos SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE chaves_pix SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE configuracoes SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE precos_marketplace SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
UPDATE marketplaces SET user_id = 'SEU_USER_ID_AQUI' WHERE user_id IS NULL;
*/

-- ====================
-- PASSO 3: REMOVER POLÍTICAS RLS ANTIGAS
-- ====================

-- Remover todas as políticas públicas antigas
DROP POLICY IF EXISTS "Permitir acesso público" ON categorias;
DROP POLICY IF EXISTS "Permitir acesso público" ON insumos;
DROP POLICY IF EXISTS "Permitir acesso público" ON produtos;
DROP POLICY IF EXISTS "Permitir acesso público" ON receitas;
DROP POLICY IF EXISTS "Permitir acesso público" ON receita_insumos;
DROP POLICY IF EXISTS "Permitir acesso público" ON precos_marketplace;
DROP POLICY IF EXISTS "Permitir acesso público" ON pedidos;
DROP POLICY IF EXISTS "Permitir acesso público" ON pedido_itens;
DROP POLICY IF EXISTS "Permitir acesso público" ON producao;
DROP POLICY IF EXISTS "Permitir acesso público" ON movimentacoes_estoque;
DROP POLICY IF EXISTS "Permitir acesso público" ON despesas;
DROP POLICY IF EXISTS "Permitir acesso público" ON equipamentos;
DROP POLICY IF EXISTS "Permitir acesso público" ON chaves_pix;
DROP POLICY IF EXISTS "Permitir acesso público" ON configuracoes;
DROP POLICY IF EXISTS "Permitir acesso público" ON marketplaces;

DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON categorias;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON insumos;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON produtos;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON receitas;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON receita_insumos;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON precos_marketplace;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON pedidos;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON pedido_itens;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON producao;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON movimentacoes_estoque;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON despesas;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON equipamentos;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON chaves_pix;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON configuracoes;
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON marketplaces;

-- ====================
-- PASSO 4: CRIAR POLÍTICAS RLS POR USUÁRIO
-- ====================

-- Cada usuário só vê/edita/deleta seus próprios dados

-- Categorias: SELECT livre (ver categorias de todos), INSERT/UPDATE/DELETE só do próprio
CREATE POLICY "Usuarios veem suas categorias" ON categorias FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem suas categorias" ON categorias FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam suas categorias" ON categorias FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam suas categorias" ON categorias FOR DELETE USING (user_id = auth.uid());

-- Insumos
CREATE POLICY "Usuarios veem seus insumos" ON insumos FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem seus insumos" ON insumos FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam seus insumos" ON insumos FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam seus insumos" ON insumos FOR DELETE USING (user_id = auth.uid());

-- Produtos
CREATE POLICY "Usuarios veem seus produtos" ON produtos FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem seus produtos" ON produtos FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam seus produtos" ON produtos FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam seus produtos" ON produtos FOR DELETE USING (user_id = auth.uid());

-- Receitas
CREATE POLICY "Usuarios veem suas receitas" ON receitas FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem suas receitas" ON receitas FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam suas receitas" ON receitas FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam suas receitas" ON receitas FOR DELETE USING (user_id = auth.uid());

-- Receita Insumos
CREATE POLICY "Usuarios veem seus receita_insumos" ON receita_insumos FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem seus receita_insumos" ON receita_insumos FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam seus receita_insumos" ON receita_insumos FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam seus receita_insumos" ON receita_insumos FOR DELETE USING (user_id = auth.uid());

-- Pedidos
CREATE POLICY "Usuarios veem seus pedidos" ON pedidos FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem seus pedidos" ON pedidos FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam seus pedidos" ON pedidos FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam seus pedidos" ON pedidos FOR DELETE USING (user_id = auth.uid());

-- Pedido Itens
CREATE POLICY "Usuarios veem seus pedido_itens" ON pedido_itens FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem seus pedido_itens" ON pedido_itens FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam seus pedido_itens" ON pedido_itens FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam seus pedido_itens" ON pedido_itens FOR DELETE USING (user_id = auth.uid());

-- Produção
CREATE POLICY "Usuarios veem sua producao" ON producao FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem sua producao" ON producao FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam sua producao" ON producao FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam sua producao" ON producao FOR DELETE USING (user_id = auth.uid());

-- Movimentações Estoque
CREATE POLICY "Usuarios veem suas movimentacoes" ON movimentacoes_estoque FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem suas movimentacoes" ON movimentacoes_estoque FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam suas movimentacoes" ON movimentacoes_estoque FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam suas movimentacoes" ON movimentacoes_estoque FOR DELETE USING (user_id = auth.uid());

-- Despesas
CREATE POLICY "Usuarios veem suas despesas" ON despesas FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem suas despesas" ON despesas FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam suas despesas" ON despesas FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam suas despesas" ON despesas FOR DELETE USING (user_id = auth.uid());

-- Equipamentos
CREATE POLICY "Usuarios veem seus equipamentos" ON equipamentos FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem seus equipamentos" ON equipamentos FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam seus equipamentos" ON equipamentos FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam seus equipamentos" ON equipamentos FOR DELETE USING (user_id = auth.uid());

-- Chaves Pix
CREATE POLICY "Usuarios veem suas chaves_pix" ON chaves_pix FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem suas chaves_pix" ON chaves_pix FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam suas chaves_pix" ON chaves_pix FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam suas chaves_pix" ON chaves_pix FOR DELETE USING (user_id = auth.uid());

-- Configurações
CREATE POLICY "Usuarios veem suas configuracoes" ON configuracoes FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem suas configuracoes" ON configuracoes FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam suas configuracoes" ON configuracoes FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam suas configuracoes" ON configuracoes FOR DELETE USING (user_id = auth.uid());

-- Preços Marketplace
CREATE POLICY "Usuarios veem seus precos" ON precos_marketplace FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem seus precos" ON precos_marketplace FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam seus precos" ON precos_marketplace FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam seus precos" ON precos_marketplace FOR DELETE USING (user_id = auth.uid());

-- Marketplaces
CREATE POLICY "Usuarios veem seus marketplaces" ON marketplaces FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Usuarios inserem seus marketplaces" ON marketplaces FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios editam seus marketplaces" ON marketplaces FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Usuarios deletam seus marketplaces" ON marketplaces FOR DELETE USING (user_id = auth.uid());

-- ====================
-- PASSO 5: VERIFICAÇÃO FINAL
-- ====================

SELECT 
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

SELECT '✅ Migração concluída! Cada usuário agora vê apenas seus próprios dados.' as status;
