-- ============================================================
-- CONFIGURAÇÕES INICIAIS PARA O SISTEMA
-- ============================================================
-- Este script insere ou atualiza as configurações padrão
-- do sistema na tabela 'configuracoes'
-- ============================================================

-- Configurações de Produção (Gás)
INSERT INTO configuracoes (chave, valor, tipo, descricao, categoria)
VALUES 
    ('peso_botijao_gas', '13', 'number', 'Peso do botijão de gás em kg', 'producao'),
    ('preco_botijao_gas', '110.00', 'number', 'Preço do botijão de gás em R$', 'financeiro')
ON CONFLICT (chave) DO UPDATE SET
    valor = EXCLUDED.valor,
    descricao = EXCLUDED.descricao,
    categoria = EXCLUDED.categoria,
    updated_at = NOW();

-- Configurações de Energia
INSERT INTO configuracoes (chave, valor, tipo, descricao, categoria)
VALUES 
    ('custo_kwh', '0.85', 'number', 'Custo por kWh de energia em R$', 'financeiro')
ON CONFLICT (chave) DO UPDATE SET
    valor = EXCLUDED.valor,
    descricao = EXCLUDED.descricao,
    categoria = EXCLUDED.categoria,
    updated_at = NOW();

-- Configurações de Mão de Obra (atualiza o que já existe no database-schema.sql)
INSERT INTO configuracoes (chave, valor, tipo, descricao, categoria)
VALUES 
    ('custo_mao_obra_hora', '25.00', 'number', 'Custo de mão de obra por hora em R$', 'financeiro')
ON CONFLICT (chave) DO UPDATE SET
    valor = EXCLUDED.valor,
    descricao = EXCLUDED.descricao,
    categoria = EXCLUDED.categoria,
    updated_at = NOW();

-- ============================================================
-- CONFIRMAÇÃO
-- ============================================================
SELECT 
    COUNT(*) as total_configuracoes,
    'Configurações iniciais criadas/atualizadas com sucesso!' as status
FROM configuracoes 
WHERE categoria IN ('producao', 'financeiro');
