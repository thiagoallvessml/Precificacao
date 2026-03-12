-- ============================================================
-- SIMULAÇÃO: Cliente usa cupom TIAGO10 e assina o plano
-- Afiliado: Tiago | ID: 266f58a7-b641-45cb-9641-07955cd27eae
-- ============================================================

-- ============================================================
-- PASSO 1: GARANTIR TABELAS AUXILIARES
-- ============================================================

CREATE TABLE IF NOT EXISTS comissoes_afiliado (
    id          BIGSERIAL PRIMARY KEY,
    afiliado_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    descricao   TEXT,
    valor       DECIMAL(10,2) NOT NULL DEFAULT 0,
    status      TEXT DEFAULT 'pendente' CHECK (status IN ('pendente','pago','recusado','cancelado')),
    pago_em     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE comissoes_afiliado ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "comissoes_public" ON comissoes_afiliado;
CREATE POLICY "comissoes_public" ON comissoes_afiliado FOR ALL USING (true) WITH CHECK (true);

CREATE TABLE IF NOT EXISTS saques_afiliado (
    id          BIGSERIAL PRIMARY KEY,
    user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    valor       DECIMAL(10,2) NOT NULL DEFAULT 0,
    chave_pix   TEXT,
    status      TEXT DEFAULT 'pendente' CHECK (status IN ('pendente','pago','recusado')),
    pago_em     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE saques_afiliado ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "saques_public" ON saques_afiliado;
CREATE POLICY "saques_public" ON saques_afiliado FOR ALL USING (true) WITH CHECK (true);


-- ============================================================
-- PASSO 2: SIMULAÇÃO — cliente usa TIAGO10 e assina
-- ============================================================

DO $$
DECLARE
    -- Afiliado real (encontrado no banco)
    v_afiliado_id    UUID    := '266f58a7-b641-45cb-9641-07955cd27eae';
    v_afiliado_nome  TEXT;
    v_cupom_id       BIGINT;
    v_cupom_codigo   TEXT    := 'TIAGO10';
    v_comissao_pct   DECIMAL;
    v_desconto_pct   DECIMAL;

    -- Cliente simulado (quem assinou usando o cupom)
    v_cliente_nome   TEXT    := 'Maria Cliente Teste';
    v_cliente_email  TEXT    := 'maria.teste@exemplo.com';
    v_cliente_id     UUID    := gen_random_uuid(); -- apenas para referência

    -- Plano e valor
    v_plano          TEXT    := 'pro';
    v_valor_plano    DECIMAL := 97.00;

    -- Calculados
    v_valor_desconto     DECIMAL;
    v_valor_com_desconto DECIMAL;
    v_valor_comissao     DECIMAL;

BEGIN

    -- ── Buscar nome do afiliado ──────────────────────────────────
    SELECT nome INTO v_afiliado_nome
    FROM perfis_usuarios WHERE id = v_afiliado_id;

    IF v_afiliado_nome IS NULL THEN
        RAISE EXCEPTION 'Afiliado com id % nao encontrado!', v_afiliado_id;
    END IF;

    -- ── Buscar cupom ─────────────────────────────────────────────
    SELECT id, comissao_percentual, desconto_percentual
    INTO v_cupom_id, v_comissao_pct, v_desconto_pct
    FROM cupons_afiliado
    WHERE codigo = v_cupom_codigo AND ativo = true;

    -- Se cupom não existir, criar agora
    IF v_cupom_id IS NULL THEN
        INSERT INTO cupons_afiliado (codigo, desconto_percentual, comissao_percentual, ativo, user_id)
        VALUES (v_cupom_codigo, 10.00, 10.00, true, v_afiliado_id)
        RETURNING id, comissao_percentual, desconto_percentual
        INTO v_cupom_id, v_comissao_pct, v_desconto_pct;

        RAISE NOTICE '>> Cupom % criado para %', v_cupom_codigo, v_afiliado_nome;
    ELSE
        -- Garantir que o cupom está vinculado ao afiliado correto
        UPDATE cupons_afiliado SET user_id = v_afiliado_id WHERE id = v_cupom_id;
        RAISE NOTICE '>> Cupom % encontrado (ID: %)', v_cupom_codigo, v_cupom_id;
    END IF;

    -- ── Calcular valores ─────────────────────────────────────────
    v_valor_desconto     := ROUND(v_valor_plano * v_desconto_pct / 100.0, 2);
    v_valor_com_desconto := v_valor_plano - v_valor_desconto;
    v_valor_comissao     := ROUND(v_valor_plano * v_comissao_pct / 100.0, 2);

    RAISE NOTICE '';
    RAISE NOTICE '>> Plano: % | Valor normal: R$ %', v_plano, v_valor_plano;
    RAISE NOTICE '>> Desconto (% pct): - R$ %', v_desconto_pct, v_valor_desconto;
    RAISE NOTICE '>> Cliente paga: R$ %', v_valor_com_desconto;
    RAISE NOTICE '>> Comissao p/ %: R$ % (% pct)', v_afiliado_nome, v_valor_comissao, v_comissao_pct;

    -- ── Registrar indicação ──────────────────────────────────────
    INSERT INTO indicacoes (
        cupom_id, nome_indicado, email_indicado, status,
        valor_assinatura, valor_comissao, valor_desconto,
        data_conversao, comissao_paga
    ) VALUES (
        v_cupom_id, v_cliente_nome, v_cliente_email, 'ativo',
        v_valor_com_desconto, v_valor_comissao, v_valor_desconto,
        NOW(), false
    );
    RAISE NOTICE '>> Indicacao registrada para %', v_cliente_nome;

    -- ── Criar comissão para o afiliado ───────────────────────────
    INSERT INTO comissoes_afiliado (afiliado_id, descricao, valor, status)
    VALUES (
        v_afiliado_id,
        format('Comissao por indicacao de %s - Plano %s', v_cliente_nome, upper(v_plano)),
        v_valor_comissao,
        'pendente'
    );
    RAISE NOTICE '>> Comissao de R$ % gerada (pendente)', v_valor_comissao;

    -- ── Atualizar saldo do afiliado ──────────────────────────────
    UPDATE perfis_usuarios
    SET saldo_afiliado = COALESCE(saldo_afiliado, 0) + v_valor_comissao
    WHERE id = v_afiliado_id;
    RAISE NOTICE '>> Saldo de % atualizado (+R$ %)', v_afiliado_nome, v_valor_comissao;

    -- (pagamentos nao inserido na simulacao: FK requer usuario real em auth.users)

    -- ── Resumo ───────────────────────────────────────────────────
    RAISE NOTICE '';
    RAISE NOTICE '=== SIMULACAO CONCLUIDA COM SUCESSO ===';
    RAISE NOTICE 'Cliente:   % (%)', v_cliente_nome, v_cliente_email;
    RAISE NOTICE 'Cupom:     %', v_cupom_codigo;
    RAISE NOTICE 'Pagou:     R$ % (economizou R$ %)', v_valor_com_desconto, v_valor_desconto;
    RAISE NOTICE 'Afiliado:  % ganhou R$ %', v_afiliado_nome, v_valor_comissao;
    RAISE NOTICE '=======================================';

END $$;


-- ============================================================
-- PASSO 3: VERIFICAR RESULTADOS
-- ============================================================

-- Saldo atualizado do Tiago
SELECT nome, email, COALESCE(saldo_afiliado, 0) AS saldo_afiliado, chave_pix
FROM perfis_usuarios
WHERE id = '266f58a7-b641-45cb-9641-07955cd27eae';

-- Comissões pendentes geradas
SELECT ca.id, pu.nome AS afiliado, ca.descricao, ca.valor, ca.status, ca.created_at
FROM comissoes_afiliado ca
JOIN perfis_usuarios pu ON pu.id = ca.afiliado_id
WHERE ca.afiliado_id = '266f58a7-b641-45cb-9641-07955cd27eae'
ORDER BY ca.created_at DESC;

-- Indicações registradas pelo cupom TIAGO10
SELECT i.id, c.codigo AS cupom, i.nome_indicado, i.valor_assinatura,
       i.valor_comissao, i.valor_desconto, i.status, i.comissao_paga
FROM indicacoes i
JOIN cupons_afiliado c ON c.id = i.cupom_id
WHERE c.codigo = 'TIAGO10'
ORDER BY i.created_at DESC;


-- ============================================================
-- PASSO 4 (OPCIONAL): SIMULAR SOLICITAÇÃO DE SAQUE DO TIAGO
-- Descomente para simular o Tiago pedindo o saque
-- ============================================================

/*

INSERT INTO saques_afiliado (user_id, valor, chave_pix, status)
SELECT
    pu.id,
    pu.saldo_afiliado,
    COALESCE(pu.chave_pix, pu.email),
    'pendente'
FROM perfis_usuarios pu
WHERE pu.id = '266f58a7-b641-45cb-9641-07955cd27eae'
  AND pu.saldo_afiliado > 0;

SELECT 'Saque do Tiago solicitado! Aparece em repasses-afiliados.html' AS status;

*/


-- ============================================================
-- PASSO 5 (OPCIONAL): SIMULAR ADMIN CONFIRMANDO O REPASSE
-- ============================================================

/*

DO $$
DECLARE
    v_user_id UUID := '266f58a7-b641-45cb-9641-07955cd27eae';
    v_saque_id BIGINT;
    v_valor    DECIMAL;
BEGIN
    SELECT id, valor INTO v_saque_id, v_valor
    FROM saques_afiliado
    WHERE user_id = v_user_id AND status = 'pendente'
    ORDER BY created_at DESC LIMIT 1;

    IF v_saque_id IS NULL THEN
        RAISE EXCEPTION 'Nenhum saque pendente do Tiago!';
    END IF;

    -- Marcar saque como pago
    UPDATE saques_afiliado SET status = 'pago', pago_em = NOW() WHERE id = v_saque_id;

    -- Marcar comissões como pagas
    UPDATE comissoes_afiliado SET status = 'pago', pago_em = NOW()
    WHERE afiliado_id = v_user_id AND status = 'pendente';

    -- Marcar indicações como pagas
    UPDATE indicacoes SET comissao_paga = true, data_pagamento_comissao = NOW()
    WHERE cupom_id IN (SELECT id FROM cupons_afiliado WHERE user_id = v_user_id)
      AND comissao_paga = false;

    -- Zerar saldo
    UPDATE perfis_usuarios SET saldo_afiliado = 0 WHERE id = v_user_id;

    -- Registrar no histórico
    INSERT INTO repasses_afiliado (nome_afiliado, valor, chave_pix, data_repasse)
    SELECT nome, v_valor, COALESCE(chave_pix, email), NOW()
    FROM perfis_usuarios WHERE id = v_user_id;

    RAISE NOTICE 'Repasse de R$ % para o Tiago confirmado!', v_valor;
END $$;

*/
