-- ============================================================
-- CORRIGIR PERMISSÕES RLS - Tabela INSUMOS
-- ============================================================

-- Este script corrige problemas de permissão na tabela insumos
-- Execute este script no SQL Editor do Supabase

-- ====================
-- 1. VERIFICAR POLÍTICAS EXISTENTES
-- ====================

-- Ver todas as políticas da tabela insumos
SELECT 
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'insumos';

-- Se não retornar nada, não há políticas!

-- ====================
-- 2. VERIFICAR SE RLS ESTÁ HABILITADO
-- ====================

SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'insumos';

-- rowsecurity = true  → RLS está habilitado
-- rowsecurity = false → RLS está desabilitado

-- ====================
-- 3. HABILITAR RLS (se estiver desabilitado)
-- ====================

ALTER TABLE insumos ENABLE ROW LEVEL SECURITY;

-- ====================
-- 4. CRIAR POLÍTICA PÚBLICA DE ACESSO
-- ====================

-- Remove política antiga se existir
DROP POLICY IF EXISTS "Permitir acesso público" ON insumos;

-- Cria nova política permitindo tudo
CREATE POLICY "Permitir acesso público" 
ON insumos 
FOR ALL 
TO public
USING (true)
WITH CHECK (true);

-- ====================
-- 5. VERIFICAR SE FUNCIONOU
-- ====================

-- Tentar selecionar dados (deve funcionar agora)
SELECT COUNT(*) FROM insumos;

-- Ver detalhes da política criada
SELECT 
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'insumos';

-- ====================
-- 6. TESTAR ACESSO DE CADA TIPO
-- ====================

-- Ingredientes
SELECT COUNT(*) FROM insumos WHERE tipo = 'ingrediente' AND ativo = true;

-- Embalagens
SELECT COUNT(*) FROM insumos WHERE tipo = 'embalagem' AND ativo = true;

-- Equipamentos
SELECT COUNT(*) FROM insumos WHERE tipo = 'equipamento' AND ativo = true;

-- ====================
-- MENSAGENS ESPERADAS
-- ====================

-- ✅ Se tudo funcionar, você deve conseguir acessar a tabela
-- ✅ A página adicionar-receita.html deve carregar os insumos

-- ====================
-- OPCIONAL: Criar políticas mais específicas
-- ====================

-- Se você quiser políticas separadas por operação:

/*
-- Permitir SELECT (leitura) para todos
DROP POLICY IF EXISTS "Permitir leitura pública" ON insumos;
CREATE POLICY "Permitir leitura pública"
ON insumos FOR SELECT
TO public
USING (true);

-- Permitir INSERT (criação) para todos
DROP POLICY IF EXISTS "Permitir criação pública" ON insumos;
CREATE POLICY "Permitir criação pública"
ON insumos FOR INSERT
TO public
WITH CHECK (true);

-- Permitir UPDATE (atualização) para todos
DROP POLICY IF EXISTS "Permitir atualização pública" ON insumos;
CREATE POLICY "Permitir atualização pública"
ON insumos FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

-- Permitir DELETE (exclusão) para todos
DROP POLICY IF EXISTS "Permitir exclusão pública" ON insumos;
CREATE POLICY "Permitir exclusão pública"
ON insumos FOR DELETE
TO public
USING (true);
*/

-- ====================
-- OUTRAS TABELAS QUE PODEM PRECISAR DE RLS
-- ====================

-- Verificar e criar políticas para outras tabelas relacionadas:

-- Categorias
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Permitir acesso público" ON categorias;
CREATE POLICY "Permitir acesso público" ON categorias FOR ALL USING (true);

-- Produtos
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Permitir acesso público" ON produtos;
CREATE POLICY "Permitir acesso público" ON produtos FOR ALL USING (true);

-- Receitas
ALTER TABLE receitas ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Permitir acesso público" ON receitas;
CREATE POLICY "Permitir acesso público" ON receitas FOR ALL USING (true);

-- Receitas_Insumos
ALTER TABLE receitas_insumos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Permitir acesso público" ON receitas_insumos;
CREATE POLICY "Permitir acesso público" ON receitas_insumos FOR ALL USING (true);

-- ====================
-- VERIFICAÇÃO FINAL COMPLETA
-- ====================

SELECT 
    'insumos' as tabela,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE tablename = 'insumos'

UNION ALL

SELECT 
    'categorias' as tabela,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE tablename = 'categorias'

UNION ALL

SELECT 
    'produtos' as tabela,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE tablename = 'produtos'

UNION ALL

SELECT 
    'receitas' as tabela,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE tablename = 'receitas'

UNION ALL

SELECT 
    'receitas_insumos' as tabela,
    COUNT(*) as total_politicas
FROM pg_policies
WHERE tablename = 'receitas_insumos';

-- Todas devem ter pelo menos 1 política!

-- ====================
-- SUCESSO! ✅
-- ====================

SELECT '✅ Políticas RLS configuradas com sucesso!' as status;
SELECT 'Agora recarregue a página adicionar-receita.html' as proximo_passo;
