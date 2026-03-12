-- ============================================================
-- FIX: Admin não consegue ver lista de afiliados em gestao-afiliados.html
-- CAUSA 1: RETURNS TABLE com coluna "id" causava ambiguidade no WHERE
--           da checagem de admin (id = auth.uid() era ambíguo).
-- CAUSA 2: RLS bloqueia queries diretas do admin em tabelas de outros usuários.
-- SOLUÇÃO: Funções RPC com SECURITY DEFINER + aliases explícitos em todos
--          os column references para evitar ambiguidade.
--
-- Como rodar:
--   1. Acesse: https://supabase.com/dashboard/project/SEU_PROJETO/sql/new
--   2. Cole este SQL completo e clique em "Run"
-- ============================================================


-- ============================================================
-- DIAGNÓSTICO: verificar afiliados e seus cupons
-- ============================================================
SELECT
    p.id,
    p.nome,
    p.email,
    p.role,
    p.codigo_indicacao,
    c.codigo    AS cupom_codigo,
    c.ativo     AS cupom_ativo
FROM perfis_usuarios p
LEFT JOIN cupons_afiliado c ON c.user_id = p.id
WHERE p.role = 'afiliado'
ORDER BY p.created_at DESC;


-- ============================================================
-- 1. RPC: Listar afiliados pela ROLE
-- ============================================================
DROP FUNCTION IF EXISTS admin_listar_afiliados();
CREATE OR REPLACE FUNCTION admin_listar_afiliados()
RETURNS TABLE (
    afil_id             UUID,
    afil_nome           TEXT,
    afil_email          TEXT,
    afil_chave_pix      TEXT,
    afil_saldo          NUMERIC,
    afil_created_at     TIMESTAMPTZ,
    afil_codigo         TEXT,
    afil_desconto       NUMERIC,
    afil_comissao       NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_caller_role TEXT;
BEGIN
    -- Verificar se o chamador é admin (usando variável para evitar ambiguidade)
    SELECT perfis_usuarios.role INTO v_caller_role
    FROM perfis_usuarios
    WHERE perfis_usuarios.id = auth.uid();

    IF v_caller_role IS DISTINCT FROM 'admin' THEN
        RAISE EXCEPTION 'Acesso negado: apenas administradores';
    END IF;

    RETURN QUERY
        SELECT
            p.id            AS afil_id,
            p.nome          AS afil_nome,
            p.email         AS afil_email,
            p.chave_pix     AS afil_chave_pix,
            COALESCE(p.saldo_afiliado, 0)               AS afil_saldo,
            p.created_at    AS afil_created_at,
            COALESCE(c.codigo, p.codigo_indicacao)       AS afil_codigo,
            COALESCE(c.desconto_percentual, 10::NUMERIC) AS afil_desconto,
            COALESCE(c.comissao_percentual, 10::NUMERIC) AS afil_comissao
        FROM perfis_usuarios p
        LEFT JOIN cupons_afiliado c
            ON c.user_id = p.id AND c.ativo = true
        WHERE p.role = 'afiliado'
        ORDER BY p.created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_listar_afiliados() TO authenticated;


-- ============================================================
-- 2. RPC: Listar todas as comissões
-- ============================================================
DROP FUNCTION IF EXISTS admin_listar_comissoes();
CREATE OR REPLACE FUNCTION admin_listar_comissoes()
RETURNS SETOF comissoes_afiliado
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_caller_role TEXT;
BEGIN
    SELECT perfis_usuarios.role INTO v_caller_role
    FROM perfis_usuarios
    WHERE perfis_usuarios.id = auth.uid();

    IF v_caller_role IS DISTINCT FROM 'admin' THEN
        RAISE EXCEPTION 'Acesso negado: apenas administradores';
    END IF;

    RETURN QUERY SELECT * FROM comissoes_afiliado;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_listar_comissoes() TO authenticated;


-- ============================================================
-- 3. RPC: Listar saques pendentes
-- ============================================================
DROP FUNCTION IF EXISTS admin_listar_saques_pendentes();
CREATE OR REPLACE FUNCTION admin_listar_saques_pendentes()
RETURNS SETOF saques_afiliado
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_caller_role TEXT;
BEGIN
    SELECT perfis_usuarios.role INTO v_caller_role
    FROM perfis_usuarios
    WHERE perfis_usuarios.id = auth.uid();

    IF v_caller_role IS DISTINCT FROM 'admin' THEN
        RAISE EXCEPTION 'Acesso negado: apenas administradores';
    END IF;

    RETURN QUERY
        SELECT * FROM saques_afiliado
        WHERE status = 'pendente'
        ORDER BY created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_listar_saques_pendentes() TO authenticated;


-- ============================================================
-- Verificar funções criadas
-- ============================================================
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_name IN (
    'admin_listar_afiliados',
    'admin_listar_comissoes',
    'admin_listar_saques_pendentes'
)
AND routine_schema = 'public';

SELECT '✅ Funções RPC de admin para afiliados criadas com sucesso!' AS resultado;
