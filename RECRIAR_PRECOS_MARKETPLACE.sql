-- ============================================================
-- RECRIAR TABELA precos_marketplace CORRETAMENTE
-- ============================================================
-- Este script recria a tabela com a estrutura correta
-- ATENÇÃO: Vai apagar dados existentes (se houver)
-- ============================================================

-- 1. Dropar tabela antiga
DROP TABLE IF EXISTS precos_marketplace CASCADE;

-- 2. Criar tabela com estrutura CORRETA
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

-- 3. Comentários
COMMENT ON TABLE precos_marketplace IS 'Preços específicos por marketplace (categoria)';
COMMENT ON COLUMN precos_marketplace.categoria_marketplace_id IS 'ID da categoria tipo marketplace';

-- 4. Índices
CREATE INDEX idx_precos_produto ON precos_marketplace(produto_id);
CREATE INDEX idx_precos_marketplace ON precos_marketplace(categoria_marketplace_id);

-- 5. Habilitar RLS
ALTER TABLE precos_marketplace ENABLE ROW LEVEL SECURITY;

-- 6. Políticas públicas (DESENVOLVIMENTO)
CREATE POLICY "Permitir leitura pública de precos_marketplace"
ON precos_marketplace FOR SELECT USING (true);

CREATE POLICY "Permitir inserção pública de precos_marketplace"
ON precos_marketplace FOR INSERT WITH CHECK (true);

CREATE POLICY "Permitir atualização pública de precos_marketplace"
ON precos_marketplace FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Permitir exclusão pública de precos_marketplace"
ON precos_marketplace FOR DELETE USING (true);

-- 7. Verificar estrutura criada
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'precos_marketplace'
ORDER BY ordinal_position;

-- 8. Verificar foreign keys
SELECT
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS references_table,
    ccu.column_name AS references_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'precos_marketplace'
    AND tc.constraint_type = 'FOREIGN KEY';

-- ✅ PRONTO! Tabela recriada com estrutura correta
-- Resultado esperado na verificação:
-- categoria_marketplace_id | bigint | NO
