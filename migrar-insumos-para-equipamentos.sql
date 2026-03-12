-- ============================================================
-- MIGRAÇÃO: Mover equipamentos da tabela insumos → equipamentos
-- Execute no Supabase SQL Editor
-- ============================================================

-- PASSO 1: Ver o que existe em insumos (diagnóstico antes de migrar)
SELECT
    i.id,
    i.nome,
    i.custo_unitario,
    i.unidade_medida,
    i.user_id,
    i.created_at,
    i.observacoes
FROM insumos i
WHERE i.tipo = 'equipamento'
  AND (i.ativo = true OR i.ativo IS NULL)
ORDER BY i.created_at;

-- ============================================================
-- PASSO 2: Executar a migração
-- Copia os dados de insumos → equipamentos mapeando as colunas
-- ============================================================

INSERT INTO public.equipamentos (
    nome,
    descricao,
    valor_compra,
    data_compra,
    vida_util_meses,
    depreciacao_mensal,
    custo_hora,
    tipo_equipamento,
    potencia_watts,
    status,
    observacoes,
    user_id,
    created_at,
    updated_at
)
SELECT
    i.nome,

    -- descricao vem do JSON de observacoes
    CASE
        WHEN i.observacoes IS NOT NULL AND i.observacoes != ''
        THEN (i.observacoes::jsonb ->> 'descricao')
        ELSE NULL
    END AS descricao,

    -- valor_compra do JSON ou NULL
    CASE
        WHEN i.observacoes IS NOT NULL AND i.observacoes != ''
        THEN NULLIF((i.observacoes::jsonb ->> 'valor_compra'), '')::NUMERIC
        ELSE NULL
    END AS valor_compra,

    -- data_compra do JSON ou NULL
    CASE
        WHEN i.observacoes IS NOT NULL AND i.observacoes != ''
             AND (i.observacoes::jsonb ->> 'data_compra') IS NOT NULL
             AND (i.observacoes::jsonb ->> 'data_compra') != ''
        THEN (i.observacoes::jsonb ->> 'data_compra')::DATE
        ELSE NULL
    END AS data_compra,

    -- vida_util_meses do JSON ou NULL
    CASE
        WHEN i.observacoes IS NOT NULL AND i.observacoes != ''
        THEN NULLIF((i.observacoes::jsonb ->> 'vida_util_meses'), '')::INTEGER
        ELSE NULL
    END AS vida_util_meses,

    -- depreciacao_mensal calculada
    CASE
        WHEN i.observacoes IS NOT NULL AND i.observacoes != ''
             AND NULLIF((i.observacoes::jsonb ->> 'valor_compra'), '') IS NOT NULL
             AND NULLIF((i.observacoes::jsonb ->> 'vida_util_meses'), '') IS NOT NULL
             AND (i.observacoes::jsonb ->> 'vida_util_meses')::INTEGER > 0
        THEN ROUND(
            (i.observacoes::jsonb ->> 'valor_compra')::NUMERIC /
            (i.observacoes::jsonb ->> 'vida_util_meses')::INTEGER,
            2
        )
        ELSE NULL
    END AS depreciacao_mensal,

    -- custo_hora = custo_unitario da tabela insumos
    COALESCE(i.custo_unitario, 0) AS custo_hora,

    -- tipo_equipamento do JSON ou 'manual'
    CASE
        WHEN i.observacoes IS NOT NULL AND i.observacoes != ''
             AND (i.observacoes::jsonb ->> 'tipo_equipamento') IN ('eletrico', 'gas', 'manual')
        THEN (i.observacoes::jsonb ->> 'tipo_equipamento')
        ELSE 'manual'
    END AS tipo_equipamento,

    -- potencia_watts do JSON ou NULL
    CASE
        WHEN i.observacoes IS NOT NULL AND i.observacoes != ''
        THEN NULLIF((i.observacoes::jsonb ->> 'potencia_watts'), '')::INTEGER
        ELSE NULL
    END AS potencia_watts,

    -- status: ativo por padrão
    'ativo' AS status,

    -- observacoes: manter o JSON original (tem níveis de gás, etc.)
    i.observacoes,

    -- user_id do registro original
    i.user_id,

    -- timestamps
    COALESCE(i.created_at, NOW()) AS created_at,
    NOW() AS updated_at

FROM public.insumos i
WHERE i.tipo = 'equipamento'
  AND (i.ativo = true OR i.ativo IS NULL)
  -- Evitar duplicatas: não inserir se já existe equipamento com mesmo nome e user_id
  AND NOT EXISTS (
      SELECT 1 FROM public.equipamentos e
      WHERE e.nome = i.nome
        AND e.user_id = i.user_id
  );

-- ============================================================
-- PASSO 3: Verificar o resultado da migração
-- ============================================================

SELECT
    'insumos (tipo=equipamento)' AS origem,
    COUNT(*) AS total
FROM insumos
WHERE tipo = 'equipamento' AND (ativo = true OR ativo IS NULL)

UNION ALL

SELECT
    'equipamentos (após migração)' AS origem,
    COUNT(*) AS total
FROM equipamentos
WHERE status != 'inativo';

-- ============================================================
-- PASSO 4: Ver os equipamentos migrados
-- ============================================================

SELECT
    id,
    nome,
    tipo_equipamento,
    potencia_watts,
    custo_hora,
    valor_compra,
    vida_util_meses,
    status,
    user_id,
    created_at
FROM public.equipamentos
ORDER BY created_at DESC;

-- ============================================================
-- PASSO 5: Marcar os registros migrados como inativos em insumos
-- (só execute após confirmar que a migração deu certo no Passo 3!)
-- ============================================================

/*
UPDATE public.insumos
SET ativo = false
WHERE tipo = 'equipamento'
  AND (ativo = true OR ativo IS NULL);

SELECT 'Registros marcados como inativos em insumos: ' || COUNT(*) AS resultado
FROM insumos WHERE tipo = 'equipamento' AND ativo = false;
*/

SELECT '✅ Migração concluída! Verifique os dados acima antes de executar o Passo 5.' AS aviso;
