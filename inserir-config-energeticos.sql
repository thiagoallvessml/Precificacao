-- ============================================================
-- INSERIR CONFIGURAÇÕES DE CUSTOS ENERGÉTICOS
-- ============================================================

-- ====================
-- 1. CUSTO DE ENERGIA ELÉTRICA (kWh)
-- ====================

INSERT INTO configuracoes (chave, valor, tipo, descricao, categoria)
VALUES (
    'custo_kwh',
    '0.85',  -- R$ 0,85 por kWh (ajuste conforme sua conta de luz)
    'number',
    'Custo da energia elétrica por kWh',
    'producao'
)
ON CONFLICT (chave) DO UPDATE SET
    valor = EXCLUDED.valor,
    tipo = EXCLUDED.tipo,
    descricao = EXCLUDED.descricao,
    categoria = EXCLUDED.categoria,
    updated_at = NOW();

-- ====================
-- 2. CUSTO DE GÁS POR HORA
-- ====================

INSERT INTO configuracoes (chave, valor, tipo, descricao, categoria)
VALUES (
    'custo_gas_hora',
    '2.00',  -- R$ 2,00 por hora de uso (ajuste conforme necessário)
    'number',
    'Custo do gás por hora de uso',
    'producao'
)
ON CONFLICT (chave) DO UPDATE SET
    valor = EXCLUDED.valor,
    tipo = EXCLUDED.tipo,
    descricao = EXCLUDED.descricao,
    categoria = EXCLUDED.categoria,
    updated_at = NOW();

-- ====================
-- 3. VERIFICAR SE INSERIU
-- ====================

SELECT 
    chave,
    valor,
    tipo,
    descricao,
    categoria
FROM configuracoes 
WHERE chave IN ('custo_kwh', 'custo_gas_hora', 'custo_mao_obra_hora')
ORDER BY chave;

-- Deve retornar 3 registros:
-- custo_gas_hora       | 2.00    | number | Custo do gás por hora de uso
-- custo_kwh            | 0.85    | number | Custo da energia elétrica por kWh
-- custo_mao_obra_hora  | 15.00   | number | Custo da mão de obra por hora

-- ====================
-- 4. ATUALIZAR VALORES (se necessário)
-- ====================

-- Para alterar o custo de kWh:
-- UPDATE configuracoes 
-- SET valor = '0.95'  -- Novo valor em R$/kWh
-- WHERE chave = 'custo_kwh';

-- Para alterar o custo de gás:
-- UPDATE configuracoes 
-- SET valor = '2.50'  -- Novo valor em R$/hora
-- WHERE chave = 'custo_gas_hora';

-- ====================
-- EXEMPLOS DE CÁLCULO
-- ====================

/*
EXEMPLO 1: Freezer Elétrico
--------------------------
- Potência: 150W
- Tempo de uso: 3 horas (receita fica 3h no freezer)
- Custo kWh: R$ 0,85

Cálculo:
Potência kW = 150W / 1000 = 0,15 kW
Custo/hora = 0,15 kW × R$ 0,85 = R$ 0,1275/hora
Custo total = R$ 0,1275 × 3h = R$ 0,3825

EXEMPLO 2: Fogão a Gás
--------------------------
- Tempo de preparo: 45 minutos = 0,75 horas
- Custo gás/hora: R$ 2,00

Cálculo:
Custo total = R$ 2,00 × 0,75h = R$ 1,50

EXEMPLO 3: Batedeira Elétrica
--------------------------
- Potência: 300W
- Tempo de uso: 10 minutos = 0,167 horas
- Custo kWh: R$ 0,85

Cálculo:
Potência kW = 300W / 1000 = 0,3 kW
Custo/hora = 0,3 kW × R$ 0,85 = R$ 0,255/hora
Custo total = R$ 0,255 × 0,167h = R$ 0,0426
*/

-- ====================
-- 5. CRIAR POLÍTICA RLS (se necessário)
-- ====================

ALTER TABLE configuracoes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Permitir acesso público" ON configuracoes;
CREATE POLICY "Permitir acesso público" ON configuracoes FOR ALL USING (true);

-- ====================
-- SUCESSO! ✅
-- ====================

SELECT '✅ Configurações de custos energéticos criadas com sucesso!' as status;

-- ====================
-- TABELA DE REFERÊNCIA
-- ====================

/*
RESUMO DAS CONFIGURAÇÕES DE PRODUÇÃO:
--------------------------------------
| Chave               | Valor | Unidade    | Descrição                        |
|---------------------|-------|------------|----------------------------------|
| custo_kwh           | 0.85  | R$/kWh     | Custo energia elétrica           |
| custo_gas_hora      | 2.00  | R$/hora    | Custo gás por hora               |
| custo_mao_obra_hora | 15.00 | R$/hora    | Custo mão de obra por hora       |

COMO É USADO NAS RECEITAS:
--------------------------
1. Equipamentos Elétricos:
   Custo = (Potência_Watts / 1000) × custo_kwh × (tempo_minutos / 60)

2. Equipamentos a Gás:
   Custo = custo_gas_hora × (tempo_minutos / 60)

3. Mão de Obra:
   Custo = custo_mao_obra_hora × (tempo_preparo_minutos / 60)
*/
