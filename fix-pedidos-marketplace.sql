-- ============================================================
-- CORRIGIR TABELA PEDIDOS: Usar Categorias Marketplace
-- ============================================================

-- 1. Ver estrutura atual
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'pedidos' 
ORDER BY ordinal_position;

-- 2. Dropar constraint antiga
ALTER TABLE pedidos 
DROP CONSTRAINT IF EXISTS pedidos_marketplace_id_fkey;

-- 3. Renomear coluna
ALTER TABLE pedidos 
RENAME COLUMN marketplace_id TO categoria_marketplace_id;

-- 4. Adicionar nova foreign key
ALTER TABLE pedidos 
ADD CONSTRAINT pedidos_categoria_marketplace_fkey 
FOREIGN KEY (categoria_marketplace_id) 
REFERENCES categorias(id) 
ON DELETE SET NULL;

-- 5. Verificar alteração
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'pedidos' 
AND column_name LIKE '%marketplace%';

-- Resultado esperado:
-- categoria_marketplace_id | bigint
