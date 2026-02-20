-- Migrar campo tipo de insumos para usar categoria_id

-- Passo 1: Adicionar nova coluna categoria_id
ALTER TABLE insumos 
ADD COLUMN IF NOT EXISTS categoria_id BIGINT REFERENCES categorias(id) ON DELETE SET NULL;

-- Passo 2: Popular categoria_id baseado no tipo antigo (se necessário)
-- Execute apenas se já tiver dados:
/*
UPDATE insumos 
SET categoria_id = (
    SELECT id FROM categorias 
    WHERE tipo = 'insumos' 
    AND LOWER(nome) LIKE '%' || LOWER(insumos.tipo) || '%'
    LIMIT 1
);
*/

-- Passo 3: Remover constraint antigo e renomear coluna
-- ATENÇÃO: Isso vai apagar o campo 'tipo' antigo!
-- Comente estas linhas se quiser manter os dois campos temporariamente
ALTER TABLE insumos DROP COLUMN IF EXISTS tipo;
ALTER TABLE insumos RENAME COLUMN categoria_id TO tipo;

-- Passo 4: Adicionar comentário
COMMENT ON COLUMN insumos.tipo IS 'ID da categoria de insumo (referencia categorias.id)';
