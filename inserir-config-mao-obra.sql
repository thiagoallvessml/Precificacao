-- ============================================================
-- INSERIR CONFIGURAÇÃO DE CUSTO DE MÃO DE OBRA
-- ============================================================

-- Esta configuração é usada para calcular o custo de mão de obra
-- nas receitas baseado no tempo de preparo

-- ====================
-- 1. VERIFICAR SE JÁ EXISTE
-- ====================

SELECT * FROM configuracoes WHERE chave = 'custo_mao_obra_hora';

-- ====================
-- 2. INSERIR SE NÃO EXISTIR
-- ====================

INSERT INTO configuracoes (chave, valor, tipo, descricao, categoria)
VALUES (
    'custo_mao_obra_hora',
    '15.00',  -- R$ 15,00 por hora (ajuste conforme necessário)
    'number',
    'Custo da mão de obra por hora trabalhada',
    'producao'
)
ON CONFLICT (chave) DO UPDATE SET
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
WHERE chave = 'custo_mao_obra_hora';

-- ====================
-- 4. ATUALIZAR O VALOR (se necessário)
-- ====================

-- Para alterar o custo de R$ 15/h para outro valor:
-- UPDATE configuracoes 
-- SET valor = '20.00'  -- Novo valor em reais por hora
-- WHERE chave = 'custo_mao_obra_hora';

-- ====================
-- EXEMPLOS DE CÁLCULO
-- ====================

/*
EXEMPLO 1:
- Tempo de preparo: 60 minutos
- Custo mão de obra: R$ 15/hora
- Custo total de mão de obra: R$ 15 * (60/60) = R$ 15,00

EXEMPLO 2:
- Tempo de preparo: 30 minutos
- Custo mão de obra: R$ 15/hora
- Custo total de mão de obra: R$ 15 * (30/60) = R$ 7,50

EXEMPLO 3:
- Tempo de preparo: 90 minutos
- Custo mão de obra: R$ 15/hora
- Custo total de mão de obra: R$ 15 * (90/60) = R$ 22,50
*/

-- ====================
-- OPCIONAL: Criar outras configurações relacionadas
-- ====================

-- Criar política RLS se necessário
ALTER TABLE configuracoes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Permitir acesso público" ON configuracoes;
CREATE POLICY "Permitir acesso público" ON configuracoes FOR ALL USING (true);

-- ====================
-- SUCESSO! ✅
-- ====================

SELECT '✅ Configuração de custo de mão de obra criada com sucesso!' as status;
