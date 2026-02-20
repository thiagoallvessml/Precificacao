-- ============================================================
-- CATEGORIAS INICIAIS (OPCIONAL)
-- ============================================================
-- Execute este SQL no Supabase para criar categorias padrão
-- Você pode pular este passo e criar tudo pela interface
-- ============================================================

-- PRODUTOS
INSERT INTO categorias (nome, tipo, icone, descricao) VALUES
('Geladinhos', 'produtos', 'ac_unit', 'Geladinhos tradicionais'),
('Picolés', 'produtos', 'icecream', 'Picolés gourmet'),
('Bolos', 'produtos', 'cake', 'Bolos e tortas');

-- MARKETPLACE
INSERT INTO categorias (nome, tipo, icone, descricao) VALUES
('iFood', 'marketplace', 'storefront', 'Vendas via iFood'),
('WhatsApp', 'marketplace', 'chat', 'Pedidos diretos'),
('Loja Física', 'marketplace', 'store', 'Vendas presenciais');

-- INSUMOS
INSERT INTO categorias (nome, tipo, icone, descricao) VALUES
('Ingredientes', 'insumos', 'restaurant', 'Matéria-prima'),
('Embalagens', 'insumos', 'inventory_2', 'Embalagens e recipientes'),
('Equipamentos', 'insumos', 'kitchen', 'Utensílios e equipamentos');

-- DESPESAS
INSERT INTO categorias (nome, tipo, icone, descricao) VALUES
('Fixas', 'despesas', 'receipt_long', 'Despesas fixas mensais'),
('Variáveis', 'despesas', 'trending_up', 'Despesas variáveis'),
('Marketing', 'despesas', 'campaign', 'Anúncios e divulgação');

-- Verificar
SELECT tipo, COUNT(*) as total FROM categorias GROUP BY tipo ORDER BY tipo;
