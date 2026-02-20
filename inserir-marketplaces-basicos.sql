-- ============================================================
-- INSERIR MARKETPLACES BÁSICOS
-- ============================================================
-- Este script cria marketplaces padrão se ainda não existirem
-- ============================================================

-- 1. Criar categoria para marketplaces (se não existir)
INSERT INTO categorias (nome, tipo, icone, descricao, ativo)
VALUES ('Vendas Online', 'marketplace', 'storefront', 'Canais de venda online', true)
ON CONFLICT DO NOTHING;

-- 2. Inserir marketplaces básicos
-- iFood
INSERT INTO marketplaces (nome, taxa_operacional, icone, descricao, ativo, cor)
VALUES (
    'iFood',
    27.00, -- 27% de taxa
    'restaurant',
    'Delivery via iFood',
    true,
    '#EA1D2C'
)
ON CONFLICT DO NOTHING;

-- WhatsApp
INSERT INTO marketplaces (nome, taxa_operacional, icone, descricao, ativo, cor)
VALUES (
    'WhatsApp',
    0.00, -- Sem taxa
    'chat',
    'Vendas via WhatsApp',
    true,
    '#25D366'
)
ON CONFLICT DO NOTHING;

-- Loja Física
INSERT INTO marketplaces (nome, taxa_operacional, icone, descricao, ativo, cor)
VALUES (
    'Loja Física',
    0.00, -- Sem taxa
    'store',
    'Vendas presenciais',
    true,
    '#6366F1'
)
ON CONFLICT DO NOTHING;

-- Rappi
INSERT INTO marketplaces (nome, taxa_operacional, icone, descricao, ativo, cor)
VALUES (
    'Rappi',
    25.00, -- 25% de taxa
    'delivery_dining',
    'Delivery via Rappi',
    true,
    '#FF4500'
)
ON CONFLICT DO NOTHING;

-- Instagram
INSERT INTO marketplaces (nome, taxa_operacional, icone, descricao, ativo, cor)
VALUES (
    'Instagram',
    0.00, -- Sem taxa
    'photo_camera',
    'Vendas via Instagram Direct',
    true,
    '#E4405F'
)
ON CONFLICT DO NOTHING;

-- 3. Verificar marketplaces criados
SELECT 
    id,
    nome,
    taxa_operacional,
    ativo
FROM marketplaces
ORDER BY id;
