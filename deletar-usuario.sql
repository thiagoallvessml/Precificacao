-- ============================================================
-- DELETAR TODOS OS DADOS DO USUÁRIO
-- User ID: 9a6ff8d4-c227-46c9-a959-a82b1db93623
--
-- ⚠️ ATENÇÃO: OPERAÇÃO IRREVERSÍVEL!
-- Execute com cuidado. Faça backup antes se necessário.
-- ============================================================

-- PASSO 1: Verificar quem é o usuário antes de deletar
SELECT
    u.id,
    u.email,
    u.created_at,
    p.nome,
    p.role,
    p.plano
FROM auth.users u
LEFT JOIN public.perfis_usuarios p ON p.id = u.id
WHERE u.id = '9a6ff8d4-c227-46c9-a959-a82b1db93623';

-- PASSO 2: Ver o volume de dados do usuário
SELECT
    (SELECT COUNT(*) FROM public.insumos          WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623') AS insumos,
    (SELECT COUNT(*) FROM public.receitas         WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623') AS receitas,
    (SELECT COUNT(*) FROM public.produtos         WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623') AS produtos,
    (SELECT COUNT(*) FROM public.producao         WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623') AS producoes,
    (SELECT COUNT(*) FROM public.pedidos          WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623') AS pedidos,
    (SELECT COUNT(*) FROM public.feedbacks        WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623') AS feedbacks,
    (SELECT COUNT(*) FROM public.page_views       WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623') AS page_views,
    (SELECT COUNT(*) FROM public.saques_afiliado  WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623') AS saques;

-- ============================================================
-- PASSO 3: DELETAR (descomente após confirmar os dados acima)
-- ============================================================

/*

DO $$
DECLARE
    uid TEXT := '9a6ff8d4-c227-46c9-a959-a82b1db93623';
BEGIN
    -- Dados de operação
    DELETE FROM public.producao          WHERE user_id = uid::uuid; RAISE NOTICE 'producao ok';
    DELETE FROM public.pedidos           WHERE user_id = uid::uuid; RAISE NOTICE 'pedidos ok';

    BEGIN DELETE FROM public.vendas      WHERE user_id = uid::uuid;
    EXCEPTION WHEN undefined_table THEN RAISE NOTICE 'vendas: tabela nao existe, pulando'; END;

    BEGIN DELETE FROM public.combos      WHERE user_id = uid::uuid;
    EXCEPTION WHEN undefined_table THEN RAISE NOTICE 'combos: tabela nao existe, pulando'; END;

    -- Receitas
    DELETE FROM public.receitas_insumos
        WHERE receita_id IN (SELECT id FROM public.receitas WHERE user_id = uid::uuid);
    DELETE FROM public.receitas          WHERE user_id = uid::uuid; RAISE NOTICE 'receitas ok';

    -- Produtos
    DELETE FROM public.produtos          WHERE user_id = uid::uuid; RAISE NOTICE 'produtos ok';

    -- Insumos
    DELETE FROM public.insumos           WHERE user_id = uid::uuid; RAISE NOTICE 'insumos ok';

    -- Financeiro
    BEGIN DELETE FROM public.saques_afiliado    WHERE user_id = uid::uuid;
    EXCEPTION WHEN undefined_table THEN RAISE NOTICE 'saques_afiliado: pulando'; END;

    BEGIN DELETE FROM public.comissoes_afiliado WHERE afiliado_id = uid::uuid;
    EXCEPTION WHEN undefined_table THEN RAISE NOTICE 'comissoes_afiliado: pulando'; END;

    -- Analytics e feedback
    BEGIN DELETE FROM public.feedbacks   WHERE user_id = uid::uuid;
    EXCEPTION WHEN undefined_table THEN RAISE NOTICE 'feedbacks: pulando'; END;

    BEGIN DELETE FROM public.page_views  WHERE user_id = uid::uuid;
    EXCEPTION WHEN undefined_table THEN RAISE NOTICE 'page_views: pulando'; END;

    -- Perfil
    DELETE FROM public.perfis_usuarios   WHERE id = uid::uuid; RAISE NOTICE 'perfil ok';

    -- OPCIONAL: remover login (descomente se quiser)
    -- DELETE FROM auth.users WHERE id = uid::uuid;

    RAISE NOTICE '✅ Todos os dados do usuário foram deletados!';
END $$;


*/

SELECT '👆 Confirme os dados no PASSO 2, depois descomente o bloco do PASSO 3' AS instrucao;

