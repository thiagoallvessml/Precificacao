-- ============================================================
-- DIAGNÓSTICO E FIX: Ingredientes/Embalagens sumidos (user_id NULL)
-- Execute no Supabase SQL Editor
-- ============================================================

-- PASSO 1: Ver quantos insumos estão sem user_id
SELECT
    tipo,
    COUNT(*) AS total,
    COUNT(user_id) AS com_user_id,
    COUNT(*) - COUNT(user_id) AS sem_user_id
FROM insumos
WHERE ativo = true OR ativo IS NULL
GROUP BY tipo
ORDER BY tipo;

-- PASSO 2: Ver as policies RLS atuais de insumos
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'insumos'
ORDER BY cmd, policyname;

-- PASSO 3: Descobrir seu user_id (usuário admin/dono)
-- Cole o resultado aqui para usar no PASSO 4
SELECT
    u.id,
    u.email,
    u.created_at
FROM auth.users u
ORDER BY u.created_at ASC
LIMIT 10;

-- ============================================================
-- PASSO 4: Atribuir insumos sem user_id ao usuário correto
-- SUBSTITUA 'SEU_USER_ID_AQUI' pelo UUID do usuário correto
-- (use o resultado do PASSO 3 acima)
-- ============================================================

/*
UPDATE public.insumos
SET user_id = 'SEU_USER_ID_AQUI'
WHERE user_id IS NULL
  AND (ativo = true OR ativo IS NULL);

SELECT 'Insumos atualizados: ' || COUNT(*) AS resultado
FROM insumos
WHERE user_id = 'SEU_USER_ID_AQUI';
*/

-- ============================================================
-- ALTERNATIVA: Se quiser que TODOS os usuários vejam insumos sem dono
-- (útil para insumos de catálogo compartilhado)
-- Aplica policy mais permissiva
-- ============================================================

/*
-- Remover policy restritiva atual
DROP POLICY IF EXISTS "user_select_insumos" ON public.insumos;

-- Nova policy: ver os próprios OU os que não têm dono (compartilhados)
CREATE POLICY "user_select_insumos"
    ON public.insumos FOR SELECT
    USING (user_id = auth.uid() OR user_id IS NULL);

SELECT '✅ Policy atualizada: usuários veem os próprios + catálogo compartilhado' AS resultado;
*/

-- ============================================================
-- SOLUÇÃO MAIS SIMPLES E RÁPIDA:
-- Desabilitar RLS temporariamente na tabela insumos
-- para todos os usuários autenticados verem tudo
-- ============================================================

/*
DROP POLICY IF EXISTS "user_select_insumos" ON public.insumos;
DROP POLICY IF EXISTS "user_insert_insumos" ON public.insumos;
DROP POLICY IF EXISTS "user_update_insumos" ON public.insumos;
DROP POLICY IF EXISTS "user_delete_insumos" ON public.insumos;

CREATE POLICY "auth_users_full_access"
    ON public.insumos FOR ALL
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

SELECT '✅ Policy simplificada: qualquer usuário autenticado acessa insumos' AS resultado;
*/

SELECT '👆 Escolha uma das opções acima e descomente o bloco desejado' AS instrucao;
