-- ============================================================
-- FIX: "Database error deleting user"
-- Motivo: ainda existe FK referenciando auth.users
-- Execute no Supabase SQL Editor
-- ============================================================

-- PASSO 1: Encontrar TODAS as tabelas que referenciam auth.users
SELECT
    tc.table_schema,
    tc.table_name,
    kcu.column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.referential_constraints AS rc
    ON tc.constraint_name = rc.constraint_name
JOIN information_schema.table_constraints AS tc2
    ON rc.unique_constraint_name = tc2.constraint_name
WHERE tc2.table_name = 'users'
  AND tc2.table_schema = 'auth'
  AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;

-- PASSO 2: Verificar quais tabelas ainda têm dados deste usuário
SELECT 'perfis_usuarios' AS tabela, COUNT(*) FROM public.perfis_usuarios WHERE id = '9a6ff8d4-c227-46c9-a959-a82b1db93623'
UNION ALL
SELECT 'insumos',         COUNT(*) FROM public.insumos         WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623'
UNION ALL
SELECT 'receitas',        COUNT(*) FROM public.receitas        WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623'
UNION ALL
SELECT 'produtos',        COUNT(*) FROM public.produtos        WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623'
UNION ALL
SELECT 'producao',        COUNT(*) FROM public.producao        WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623'
UNION ALL
SELECT 'pedidos',         COUNT(*) FROM public.pedidos         WHERE user_id = '9a6ff8d4-c227-46c9-a959-a82b1db93623';

-- PASSO 3: Limpar tudo que sobrou e então deletar o perfil
DO $$
DECLARE
    uid UUID := '9a6ff8d4-c227-46c9-a959-a82b1db93623';
BEGIN
    -- Deletar de TODAS as tabelas que podem ter FK para auth.users
    -- usando EXCEPTION para ignorar tabelas inexistentes

    BEGIN DELETE FROM public.producao              WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'producao: %', SQLERRM; END;
    BEGIN DELETE FROM public.pedidos               WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'pedidos: %', SQLERRM; END;
    BEGIN DELETE FROM public.vendas                WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'vendas: %', SQLERRM; END;
    BEGIN DELETE FROM public.combos                WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'combos: %', SQLERRM; END;
    BEGIN DELETE FROM public.combo_itens           WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'combo_itens: %', SQLERRM; END;

    BEGIN DELETE FROM public.receitas_insumos
        WHERE receita_id IN (SELECT id FROM public.receitas WHERE user_id = uid);
    EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'receitas_insumos: %', SQLERRM; END;

    BEGIN DELETE FROM public.receitas              WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'receitas: %', SQLERRM; END;
    BEGIN DELETE FROM public.produtos              WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'produtos: %', SQLERRM; END;
    BEGIN DELETE FROM public.insumos               WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'insumos: %', SQLERRM; END;
    BEGIN DELETE FROM public.equipamentos          WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'equipamentos: %', SQLERRM; END;
    BEGIN DELETE FROM public.saques_afiliado       WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'saques_afiliado: %', SQLERRM; END;
    BEGIN DELETE FROM public.comissoes_afiliado    WHERE afiliado_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'comissoes: %', SQLERRM; END;
    BEGIN DELETE FROM public.feedbacks             WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'feedbacks: %', SQLERRM; END;
    BEGIN DELETE FROM public.page_views            WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'page_views: %', SQLERRM; END;
    BEGIN DELETE FROM public.assinaturas           WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'assinaturas: %', SQLERRM; END;
    BEGIN DELETE FROM public.pagamentos            WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'pagamentos: %', SQLERRM; END;
    BEGIN DELETE FROM public.notificacoes          WHERE user_id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'notificacoes: %', SQLERRM; END;

    -- Perfil DEVE ser o último (tem FK direto para auth.users)
    BEGIN DELETE FROM public.perfis_usuarios       WHERE id = uid; EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'perfis_usuarios: %', SQLERRM; END;

    RAISE NOTICE '✅ Limpeza concluída! Agora delete o usuário pelo Dashboard do Supabase.';
END $$;
