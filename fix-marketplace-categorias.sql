-- ============================================================
-- CORREÇÃO: Usar Categorias como Marketplaces
-- ============================================================
-- O sistema deve usar categorias do tipo 'marketplace' ao invés
-- da tabela marketplaces separada
-- ============================================================

-- 1. Verificar categorias de marketplace existentes
SELECT 
    id,
    nome,
    icone,
    descricao,
    ativo
FROM categorias
WHERE tipo = 'marketplace'
ORDER BY id;

-- 2. Se não houver, criar categorias de marketplace básicas
INSERT INTO categorias (nome, tipo, icone, descricao, ativo)
VALUES 
    ('iFood', 'marketplace', 'restaurant', 'Delivery via iFood', true),
    ('WhatsApp', 'marketplace', 'chat', 'Vendas via WhatsApp', true),
    ('Loja Física', 'marketplace', 'store', 'Vendas presenciais', true),
    ('Rappi', 'marketplace', 'delivery_dining', 'Delivery via Rappi', true),
    ('Instagram', 'marketplace', 'photo_camera', 'Vendas via Instagram', true)
ON CONFLICT DO NOTHING;

-- 3. Alterar tabela precos_marketplace para usar categoria_id
-- ATENÇÃO: Isso irá dropar a constraint antiga e criar uma nova
-- Faça backup antes se houver dados importantes!

-- Dropar constraint antiga
ALTER TABLE precos_marketplace 
DROP CONSTRAINT IF EXISTS precos_marketplace_marketplace_id_fkey;

-- Renomear coluna (se ainda não foi feito)
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'precos_marketplace' 
        AND column_name = 'marketplace_id'
    ) THEN
        ALTER TABLE precos_marketplace 
        RENAME COLUMN marketplace_id TO categoria_marketplace_id;
    END IF;
END $$;

-- Adicionar nova constraint para categorias
ALTER TABLE precos_marketplace 
ADD CONSTRAINT precos_marketplace_categoria_fkey 
FOREIGN KEY (categoria_marketplace_id) 
REFERENCES categorias(id) 
ON DELETE CASCADE;

-- Adicionar constraint para garantir que seja tipo marketplace
ALTER TABLE precos_marketplace 
DROP CONSTRAINT IF EXISTS check_categoria_marketplace;

-- 4. Verificar estrutura final
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'precos_marketplace'
ORDER BY ordinal_position;

-- 5. Listar categorias marketplace disponíveis
SELECT 
    id,
    nome,
    icone,
    ativo
FROM categorias
WHERE tipo = 'marketplace' AND ativo = true
ORDER BY nome;
