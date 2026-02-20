-- Adicionar campo taxa_operacional na tabela categorias
-- Para categorias do tipo 'marketplace', armazena a taxa percentual

ALTER TABLE categorias 
ADD COLUMN IF NOT EXISTS taxa_operacional DECIMAL(5,2) DEFAULT 0.00;

COMMENT ON COLUMN categorias.taxa_operacional IS 'Taxa percentual para marketplaces (0-100)';
