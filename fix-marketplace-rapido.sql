-- ============================================================
-- SOLUÇÃO RÁPIDA: Marketplace usando Categorias
-- ============================================================
-- Execute este script no Supabase SQL Editor
-- ============================================================

-- PASSO 1: Criar categorias marketplace se não existirem
INSERT INTO categorias (nome, tipo, icone, descricao, ativo)
VALUES 
    ('iFood', 'marketplace', 'restaurant', 'Delivery via iFood', true),
    ('WhatsApp', 'marketplace', 'chat', 'Vendas via WhatsApp', true),
    ('Loja Física', 'marketplace', 'store', 'Vendas presenciais', true)
ON CONFLICT DO NOTHING;

-- PASSO 2: Ver os IDs criados (IMPORTANTE: Anote-os!)
SELECT id, nome, tipo FROM categorias WHERE tipo = 'marketplace' ORDER BY id;

-- PASSO 3: Recriar tabela precos_marketplace (se estiver vazia ou quiser resetar)
-- ATENÇÃO: Isso apaga dados existentes!
DROP TABLE IF EXISTS precos_marketplace CASCADE;

CREATE TABLE precos_marketplace (
    id BIGSERIAL PRIMARY KEY,
    produto_id BIGINT NOT NULL REFERENCES produtos(id) ON DELETE CASCADE,
    categoria_marketplace_id BIGINT NOT NULL REFERENCES categorias(id) ON DELETE CASCADE,
    preco DECIMAL(10,2) NOT NULL,
    margem_lucro DECIMAL(5,2),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(produto_id, categoria_marketplace_id)
);

COMMENT ON TABLE precos_marketplace IS 'Preços específicos por marketplace (categoria)';
COMMENT ON COLUMN precos_marketplace.categoria_marketplace_id IS 'ID da categoria tipo marketplace';

-- PASSO 4: Criar índices
CREATE INDEX idx_precos_produto ON precos_marketplace(produto_id);
CREATE INDEX idx_precos_marketplace ON precos_marketplace(categoria_marketplace_id);

-- PASSO 5: Verificação final
SELECT 
    'Categorias Marketplace' as tipo,
    COUNT(*) as total
FROM categorias 
WHERE tipo = 'marketplace' AND ativo = true

UNION ALL

SELECT 
    'Preços Cadastrados' as tipo,
    COUNT(*) as total
FROM precos_marketplace;

-- ✅ PRONTO! Agora você pode:
-- 1. Ir em adicionar-produto.html → aba Precificação
-- 2. Configurar preços por marketplace
-- 3. Ver os preços corretos em vendas.html
