-- Remover constraint de tipo em insumos
-- Execute este SQL ANTES de cadastrar com categorias

-- Passo 1: Remover a constraint antiga
ALTER TABLE insumos 
DROP CONSTRAINT IF EXISTS insumos_tipo_check;

-- Passo 2: Alterar o tipo da coluna de TEXT para BIGINT
ALTER TABLE insumos 
ALTER COLUMN tipo TYPE BIGINT USING tipo::INTEGER;

-- Passo 3: Adicionar foreign key para categorias
ALTER TABLE insumos 
ADD CONSTRAINT insumos_categoria_fk 
FOREIGN KEY (tipo) REFERENCES categorias(id) ON DELETE SET NULL;

-- Passo 4: Criar índice
CREATE INDEX IF NOT EXISTS idx_insumos_tipo ON insumos(tipo);

-- Passo 5: Adicionar comentário
COMMENT ON COLUMN insumos.tipo IS 'ID da categoria de insumo (FK para categorias.id)';
