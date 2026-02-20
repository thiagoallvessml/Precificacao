-- ============================================================
-- SCHEMA DO BANCO DE DADOS - GESTÃO DE GELADINHOS
-- ============================================================
-- Criado para: Sistema de Precificação e Gestão de Geladinhos
-- Database: PostgreSQL (Supabase)
-- ============================================================

-- ==============
-- 1. CATEGORIAS
-- ==============

CREATE TABLE categorias (
    id BIGSERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    tipo TEXT NOT NULL CHECK (tipo IN ('produtos', 'marketplace', 'insumos', 'despesas')),
    icone TEXT,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE categorias IS 'Categorias para produtos, marketplaces, insumos e despesas';
COMMENT ON COLUMN categorias.tipo IS 'Tipo da categoria: produtos, marketplace, insumos ou despesas';

-- Índices
CREATE INDEX idx_categorias_tipo ON categorias(tipo);
CREATE INDEX idx_categorias_ativo ON categorias(ativo);

-- ==============
-- 2. MARKETPLACES (Canais de Venda)
-- ==============

CREATE TABLE marketplaces (
    id BIGSERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    taxa_operacional DECIMAL(5,2) DEFAULT 0.00, -- Porcentagem (ex: 27.00 para 27%)
    categoria_id BIGINT REFERENCES categorias(id) ON DELETE SET NULL,
    icone TEXT,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    cor TEXT, -- Cor hexadecimal para UI
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE marketplaces IS 'Canais de venda (iFood, WhatsApp, Loja Física, etc)';
COMMENT ON COLUMN marketplaces.taxa_operacional IS 'Taxa percentual cobrada pelo canal (0-100)';

-- Índices
CREATE INDEX idx_marketplaces_ativo ON marketplaces(ativo);

-- ==============
-- 3. INSUMOS
-- ==============

CREATE TABLE insumos (
    id BIGSERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    categoria_id BIGINT REFERENCES categorias(id) ON DELETE SET NULL,
    tipo TEXT CHECK (tipo IN ('ingrediente', 'embalagem', 'equipamento')),
    unidade_medida TEXT NOT NULL, -- 'kg', 'g', 'l', 'ml', 'un', etc
    estoque_atual DECIMAL(10,3) DEFAULT 0,
    estoque_minimo DECIMAL(10,3) DEFAULT 0,
    estoque_maximo DECIMAL(10,3),
    custo_unitario DECIMAL(10,2) NOT NULL,
    imagem_url TEXT,
    fornecedor TEXT,
    observacoes TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE insumos IS 'Insumos para produção (ingredientes, embalagens, equipamentos)';
COMMENT ON COLUMN insumos.tipo IS 'Tipo do insumo: ingrediente, embalagem ou equipamento';
COMMENT ON COLUMN insumos.estoque_atual IS 'Quantidade atual em estoque';
COMMENT ON COLUMN insumos.estoque_minimo IS 'MOQ - Minimum Order Quantity';

-- Índices
CREATE INDEX idx_insumos_tipo ON insumos(tipo);
CREATE INDEX idx_insumos_categoria ON insumos(categoria_id);
CREATE INDEX idx_insumos_ativo ON insumos(ativo);
CREATE INDEX idx_insumos_estoque_baixo ON insumos(estoque_atual) WHERE estoque_atual <= estoque_minimo;

-- ==============
-- 4. PRODUTOS
-- ==============

CREATE TABLE produtos (
    id BIGSERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    descricao TEXT,
    categoria_id BIGINT REFERENCES categorias(id) ON DELETE SET NULL,
    preco_base DECIMAL(10,2) NOT NULL,
    imagem_url TEXT,
    receita_id BIGINT, -- FK será adicionada depois que criar tabela receitas
    disponivel BOOLEAN DEFAULT true,
    destaque BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE produtos IS 'Produtos finais (geladinhos) para venda';
COMMENT ON COLUMN produtos.preco_base IS 'Preço base do produto';
COMMENT ON COLUMN produtos.receita_id IS 'Receita associada ao produto';

-- Índices
CREATE INDEX idx_produtos_categoria ON produtos(categoria_id);
CREATE INDEX idx_produtos_disponivel ON produtos(disponivel);
CREATE INDEX idx_produtos_destaque ON produtos(destaque);

-- ==============
-- 5. RECEITAS
-- ==============

CREATE TABLE receitas (
    id BIGSERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    descricao TEXT,
    rendimento_unidades INTEGER NOT NULL, -- Quantas unidades essa receita produz
    tempo_preparo INTEGER, -- em minutos
    custo_mao_obra DECIMAL(10,2) DEFAULT 0,
    instrucoes TEXT,
    imagem_url TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE receitas IS 'Receitas para produção dos produtos';
COMMENT ON COLUMN receitas.rendimento_unidades IS 'Quantidade de unidades que a receita produz';
COMMENT ON COLUMN receitas.tempo_preparo IS 'Tempo de preparo em minutos';

-- Índices
CREATE INDEX idx_receitas_ativo ON receitas(ativo);

-- Agora adiciona FK em produtos
ALTER TABLE produtos ADD CONSTRAINT fk_produtos_receita 
    FOREIGN KEY (receita_id) REFERENCES receitas(id) ON DELETE SET NULL;

-- ==============
-- 6. RECEITA_INSUMOS (Relacionamento N:N)
-- ==============

CREATE TABLE receita_insumos (
    id BIGSERIAL PRIMARY KEY,
    receita_id BIGINT NOT NULL REFERENCES receitas(id) ON DELETE CASCADE,
    insumo_id BIGINT NOT NULL REFERENCES insumos(id) ON DELETE CASCADE,
    quantidade DECIMAL(10,3) NOT NULL,
    unidade_medida TEXT NOT NULL,
    custo_unitario DECIMAL(10,2), -- Snapshot do custo no momento da receita
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(receita_id, insumo_id)
);

COMMENT ON TABLE receita_insumos IS 'Insumos usados em cada receita';
COMMENT ON COLUMN receita_insumos.quantidade IS 'Quantidade do insumo usada na receita';

-- Índices
CREATE INDEX idx_receita_insumos_receita ON receita_insumos(receita_id);
CREATE INDEX idx_receita_insumos_insumo ON receita_insumos(insumo_id);

-- ==============
-- 7. PRECOS_MARKETPLACE
-- ==============

CREATE TABLE precos_marketplace (
    id BIGSERIAL PRIMARY KEY,
    produto_id BIGINT NOT NULL REFERENCES produtos(id) ON DELETE CASCADE,
    marketplace_id BIGINT NOT NULL REFERENCES marketplaces(id) ON DELETE CASCADE,
    preco DECIMAL(10,2) NOT NULL,
    margem_lucro DECIMAL(5,2), -- Porcentagem
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(produto_id, marketplace_id)
);

COMMENT ON TABLE precos_marketplace IS 'Preços específicos de produtos por marketplace';
COMMENT ON COLUMN precos_marketplace.margem_lucro IS 'Margem de lucro percentual para este canal';

-- Índices
CREATE INDEX idx_precos_produto ON precos_marketplace(produto_id);
CREATE INDEX idx_precos_marketplace ON precos_marketplace(marketplace_id);

-- ==============
-- 8. PEDIDOS
-- ==============

CREATE TABLE pedidos (
    id BIGSERIAL PRIMARY KEY,
    numero_pedido TEXT UNIQUE NOT NULL,
    marketplace_id BIGINT REFERENCES marketplaces(id) ON DELETE SET NULL,
    cliente_nome TEXT,
    cliente_telefone TEXT,
    cliente_endereco TEXT,
    status TEXT NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente', 'em_preparo', 'pronto', 'entregue', 'cancelado')),
    valor_subtotal DECIMAL(10,2) NOT NULL,
    valor_desconto DECIMAL(10,2) DEFAULT 0,
    valor_taxa_entrega DECIMAL(10,2) DEFAULT 0,
    valor_total DECIMAL(10,2) NOT NULL,
    metodo_pagamento TEXT,
    observacoes TEXT,
    data_pedido TIMESTAMPTZ DEFAULT NOW(),
    data_entrega TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE pedidos IS 'Pedidos realizados pelos clientes';
COMMENT ON COLUMN pedidos.status IS 'Status atual do pedido';

-- Índices
CREATE INDEX idx_pedidos_status ON pedidos(status);
CREATE INDEX idx_pedidos_marketplace ON pedidos(marketplace_id);
CREATE INDEX idx_pedidos_data ON pedidos(data_pedido);

-- ==============
-- 9. PEDIDO_ITENS
-- ==============

CREATE TABLE pedido_itens (
    id BIGSERIAL PRIMARY KEY,
    pedido_id BIGINT NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_id BIGINT REFERENCES produtos(id) ON DELETE SET NULL,
    produto_nome TEXT NOT NULL, -- Snapshot do nome
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    preco_total DECIMAL(10,2) NOT NULL,
    observacoes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE pedido_itens IS 'Itens individuais de cada pedido';

-- Índices
CREATE INDEX idx_pedido_itens_pedido ON pedido_itens(pedido_id);
CREATE INDEX idx_pedido_itens_produto ON pedido_itens(produto_id);

-- ==============
-- 10. PRODUCAO
-- ==============

CREATE TABLE producao (
    id BIGSERIAL PRIMARY KEY,
    receita_id BIGINT NOT NULL REFERENCES receitas(id) ON DELETE CASCADE,
    produto_id BIGINT REFERENCES produtos(id) ON DELETE SET NULL,
    quantidade_produzida INTEGER NOT NULL,
    data_producao DATE NOT NULL,
    custo_total DECIMAL(10,2),
    observacoes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE producao IS 'Registro de lotes de produção';
COMMENT ON COLUMN producao.quantidade_produzida IS 'Quantidade de unidades produzidas';

-- Índices
CREATE INDEX idx_producao_receita ON producao(receita_id);
CREATE INDEX idx_producao_produto ON producao(produto_id);
CREATE INDEX idx_producao_data ON producao(data_producao);

-- ==============
-- 11. MOVIMENTACOES_ESTOQUE
-- ==============

CREATE TABLE movimentacoes_estoque (
    id BIGSERIAL PRIMARY KEY,
    insumo_id BIGINT NOT NULL REFERENCES insumos(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL CHECK (tipo IN ('entrada', 'saida', 'ajuste', 'perda')),
    quantidade DECIMAL(10,3) NOT NULL,
    estoque_anterior DECIMAL(10,3) NOT NULL,
    estoque_atual DECIMAL(10,3) NOT NULL,
    custo_unitario DECIMAL(10,2),
    motivo TEXT,
    referencia_tipo TEXT, -- 'producao', 'compra', 'ajuste', 'perda'
    referencia_id BIGINT, -- ID da produção, compra, etc
    usuario TEXT,
    data_movimentacao TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE movimentacoes_estoque IS 'Histórico de movimentações de estoque';
COMMENT ON COLUMN movimentacoes_estoque.tipo IS 'Tipo de movimentação: entrada, saida, ajuste ou perda';

-- Índices
CREATE INDEX idx_movimentacoes_insumo ON movimentacoes_estoque(insumo_id);
CREATE INDEX idx_movimentacoes_tipo ON movimentacoes_estoque(tipo);
CREATE INDEX idx_movimentacoes_data ON movimentacoes_estoque(data_movimentacao);

-- ==============
-- 12. DESPESAS
-- ==============

CREATE TABLE despesas (
    id BIGSERIAL PRIMARY KEY,
    descricao TEXT NOT NULL,
    categoria_id BIGINT REFERENCES categorias(id) ON DELETE SET NULL,
    valor DECIMAL(10,2) NOT NULL,
    tipo TEXT NOT NULL CHECK (tipo IN ('fixa', 'variavel')),
    data_vencimento DATE,
    data_pagamento DATE,
    status TEXT DEFAULT 'pendente' CHECK (status IN ('pendente', 'paga', 'atrasada', 'cancelada')),
    recorrente BOOLEAN DEFAULT false,
    observacoes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE despesas IS 'Despesas operacionais do negócio';
COMMENT ON COLUMN despesas.tipo IS 'Tipo de despesa: fixa ou variável';

-- Índices
CREATE INDEX idx_despesas_categoria ON despesas(categoria_id);
CREATE INDEX idx_despesas_status ON despesas(status);
CREATE INDEX idx_despesas_data_vencimento ON despesas(data_vencimento);
CREATE INDEX idx_despesas_tipo ON despesas(tipo);

-- ==============
-- 13. EQUIPAMENTOS
-- ==============

CREATE TABLE equipamentos (
    id BIGSERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    descricao TEXT,
    valor_compra DECIMAL(10,2),
    data_compra DATE,
    vida_util_meses INTEGER, -- Em meses
    depreciacao_mensal DECIMAL(10,2),
    imagem_url TEXT,
    status TEXT DEFAULT 'ativo' CHECK (status IN ('ativo', 'manutencao', 'inativo')),
    observacoes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE equipamentos IS 'Equipamentos usados na produção';
COMMENT ON COLUMN equipamentos.vida_util_meses IS 'Vida útil do equipamento em meses';

-- Índices
CREATE INDEX idx_equipamentos_status ON equipamentos(status);

-- ==============
-- 14. CHAVES_PIX
-- ==============

CREATE TABLE chaves_pix (
    id BIGSERIAL PRIMARY KEY,
    tipo TEXT NOT NULL CHECK (tipo IN ('cpf', 'cnpj', 'email', 'telefone', 'aleatoria')),
    chave TEXT NOT NULL UNIQUE,
    nome_titular TEXT NOT NULL,
    principal BOOLEAN DEFAULT false,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE chaves_pix IS 'Chaves PIX para recebimento';

-- Índices
CREATE INDEX idx_chaves_pix_principal ON chaves_pix(principal) WHERE principal = true;
CREATE INDEX idx_chaves_pix_ativo ON chaves_pix(ativo);

-- ==============
-- 15. CONFIGURACOES
-- ==============

CREATE TABLE configuracoes (
    id BIGSERIAL PRIMARY KEY,
    chave TEXT NOT NULL UNIQUE,
    valor TEXT,
    tipo TEXT DEFAULT 'string' CHECK (tipo IN ('string', 'number', 'boolean', 'json')),
    descricao TEXT,
    categoria TEXT, -- 'geral', 'financeiro', 'producao', etc
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE configuracoes IS 'Configurações gerais do sistema';

-- Índices
CREATE INDEX idx_configuracoes_chave ON configuracoes(chave);
CREATE INDEX idx_configuracoes_categoria ON configuracoes(categoria);

-- ============================================================
-- TRIGGERS PARA ATUALIZAÇÃO AUTOMÁTICA DE updated_at
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplica trigger em todas as tabelas com updated_at
CREATE TRIGGER update_categorias_updated_at BEFORE UPDATE ON categorias FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_marketplaces_updated_at BEFORE UPDATE ON marketplaces FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_insumos_updated_at BEFORE UPDATE ON insumos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_produtos_updated_at BEFORE UPDATE ON produtos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_receitas_updated_at BEFORE UPDATE ON receitas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_precos_marketplace_updated_at BEFORE UPDATE ON precos_marketplace FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_pedidos_updated_at BEFORE UPDATE ON pedidos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_despesas_updated_at BEFORE UPDATE ON despesas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_equipamentos_updated_at BEFORE UPDATE ON equipamentos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_chaves_pix_updated_at BEFORE UPDATE ON chaves_pix FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_configuracoes_updated_at BEFORE UPDATE ON configuracoes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- DADOS INICIAIS (SEED DATA)
-- ============================================================

-- Categorias de Produtos
INSERT INTO categorias (nome, tipo, icone) VALUES
    ('Cremoso', 'produtos', '🍦'),
    ('Frutas', 'produtos', '🍓'),
    ('Chocolate', 'produtos', '🍫'), ('Gourmet', 'produtos', '⭐');

-- Categorias de Marketplace
INSERT INTO categorias (nome, tipo, icone) VALUES
    ('Delivery', 'marketplace', '🛵'),
    ('Loja Física', 'marketplace', '🏪'),
    ('WhatsApp', 'marketplace', '💬');

-- Categorias de Insumos
INSERT INTO categorias (nome, tipo, icone) VALUES
    ('Ingredientes', 'insumos', '🥛'),
    ('Embalagens', 'insumos', '📦'),
    ('Equipamentos', 'insumos', '🔧');

-- Categorias de Despesas
INSERT INTO categorias (nome, tipo, icone) VALUES
    ('Aluguel e Contas', 'despesas', '🏠'),
    ('Marketing', 'despesas', '📢'),
    ('Manutenção', 'despesas', '🔧'),
    ('Salários', 'despesas', '💰');

-- Marketplaces
INSERT INTO marketplaces (nome, taxa_operacional, icone, descricao) VALUES
    ('iFood', 27.00, '🛵', 'Pedidos via iFood'),
    ('Rappi', 25.00, '🛒', 'Pedidos via Rappi'),
    ('WhatsApp', 3.50, '💬', 'Vendas diretas via WhatsApp'),
    ('Loja Física', 0.00, '🏪', 'Vendas de balcão');

-- Configurações Iniciais
INSERT INTO configuracoes (chave, valor, tipo, categoria, descricao) VALUES
    ('moeda', 'BRL', 'string', 'geral', 'Moeda padrão do sistema'),
    ('timezone', 'America/Sao_Paulo', 'string', 'geral', 'Fuso horário'),
    ('margem_lucro_padrao', '30', 'number', 'financeiro', 'Margem de lucro padrão em %'),
    ('custo_mao_obra_hora', '15.00', 'number', 'producao', 'Custo de mão de obra por hora');

-- ============================================================
-- ROW LEVEL SECURITY (RLS) - IMPORTANTE PARA SEGURANÇA
-- ============================================================

-- Habilita RLS em todas as tabelas
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE marketplaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE insumos ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE receitas ENABLE ROW LEVEL SECURITY;
ALTER TABLE receita_insumos ENABLE ROW LEVEL SECURITY;
ALTER TABLE precos_marketplace ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedido_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE producao ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE despesas ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipamentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE chaves_pix ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracoes ENABLE ROW LEVEL SECURITY;

-- Políticas de acesso (permitir tudo para usuários autenticados)
-- NOTA: Ajuste essas políticas conforme suas necessidades de segurança

CREATE POLICY "Permitir tudo para usuários autenticados" ON categorias FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON marketplaces FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON insumos FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON produtos FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON receitas FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON receita_insumos FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON precos_marketplace FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON pedidos FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON pedido_itens FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON producao FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON movimentacoes_estoque FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON despesas FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON equipamentos FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON chaves_pix FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Permitir tudo para usuários autenticados" ON configuracoes FOR ALL USING (auth.uid() IS NOT NULL);

-- Permite leitura pública (caso queira que dados sejam visíveis sem autenticação)
-- Descomente se necessário:
-- CREATE POLICY "Permitir leitura pública" ON produtos FOR SELECT USING (true);
-- CREATE POLICY "Permitir leitura pública" ON categorias FOR SELECT USING (true);
