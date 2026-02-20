# 📊 Documentação do Banco de Dados

## Visão Geral

Este documento descreve a estrutura completa do banco de dados PostgreSQL (Supabase) para o sistema de Gestão de Geladinhos.

### Estatísticas
- **Total de Tabelas**: 15
- **Total de Relacionamentos**: 12 Foreign Keys
- **Triggers**: 11 (atualização automática de `updated_at`)
- **Índices**: 35+
- **Políticas RLS**: 15 (uma por tabela)

---

## 📋 Tabelas

### 1. `categorias`
Armazena categorias para produtos, marketplaces, insumos e despesas.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| nome | TEXT | Nome da categoria |
| tipo | TEXT | Tipo: 'produtos', 'marketplace', 'insumos', 'despesas' |
| icone | TEXT | Emoji ou ícone da categoria |
| descricao | TEXT | Descrição opcional |
| ativo | BOOLEAN | Se a categoria está ativa |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

**Índices**:
- `idx_categorias_tipo` (tipo)
- `idx_categorias_ativo` (ativo)

---

### 2. `marketplaces`
Canais de venda (iFood, WhatsApp, Loja Física, etc).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| nome | TEXT | Nome do marketplace |
| taxa_operacional | DECIMAL(5,2) | Taxa percentual (ex: 27.00 para 27%) |
| categoria_id | BIGINT | FK para categorias |
| icone | TEXT | Emoji ou ícone |
| descricao | TEXT | Descrição do canal |
| ativo | BOOLEAN | Se está ativo |
| cor | TEXT | Cor hexadecimal para UI |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

**Relacionamentos**:
- `categoria_id` → `categorias.id`

**Índices**:
- `idx_marketplaces_ativo` (ativo)

---

### 3. `insumos`
Insumos para produção (ingredientes, embalagens, equipamentos).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| nome | TEXT | Nome do insumo |
| categoria_id | BIGINT | FK para categorias |
| tipo | TEXT | 'ingrediente', 'embalagem', 'equipamento' |
| unidade_medida | TEXT | 'kg', 'g', 'l', 'ml', 'un', etc |
| estoque_atual | DECIMAL(10,3) | Estoque atual |
| estoque_minimo | DECIMAL(10,3) | MOQ (Minimum Order Quantity) |
| estoque_maximo | DECIMAL(10,3) | Estoque máximo |
| custo_unitario | DECIMAL(10,2) | Custo por unidade |
| imagem_url | TEXT | URL da imagem |
| fornecedor | TEXT | Nome do fornecedor |
| observacoes | TEXT | Observações |
| ativo | BOOLEAN | Se está ativo |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

**Relacionamentos**:
- `categoria_id` → `categorias.id`

**Índices**:
- `idx_insumos_tipo` (tipo)
- `idx_insumos_categoria` (categoria_id)
- `idx_insumos_ativo` (ativo)
- `idx_insumos_estoque_baixo` (estoque_atual) WHERE estoque_atual <= estoque_minimo

---

### 4. `produtos`
Produtos finais (geladinhos) para venda.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| nome | TEXT | Nome do produto |
| descricao | TEXT | Descrição |
| categoria_id | BIGINT | FK para categorias |
| preco_base | DECIMAL(10,2) | Preço base |
| imagem_url | TEXT | URL da imagem |
| receita_id | BIGINT | FK para receitas (opcional) |
| disponivel | BOOLEAN | Se está disponível |
| destaque | BOOLEAN | Se é produto destaque |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

**Relacionamentos**:
- `categoria_id` → `categorias.id`
- `receita_id` → `receitas.id`

**Índices**:
- `idx_produtos_categoria` (categoria_id)
- `idx_produtos_disponivel` (disponivel)
- `idx_produtos_destaque` (destaque)

---

### 5. `receitas`
Receitas para produção dos produtos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| nome | TEXT | Nome da receita |
| descricao | TEXT | Descrição |
| rendimento_unidades | INTEGER | Quantas unidades a receita produz |
| tempo_preparo | INTEGER | Tempo em minutos |
| custo_mao_obra | DECIMAL(10,2) | Custo de mão de obra |
| instrucoes | TEXT | Instruções de preparo |
| imagem_url | TEXT | URL da imagem |
| ativo | BOOLEAN | Se está ativa |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

**Índices**:
- `idx_receitas_ativo` (ativo)

---

### 6. `receita_insumos`
Relacionamento N:N entre receitas e insumos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| receita_id | BIGINT | FK para receitas |
| insumo_id | BIGINT | FK para insumos |
| quantidade | DECIMAL(10,3) | Quantidade usada |
| unidade_medida | TEXT | Unidade de medida |
| custo_unitario | DECIMAL(10,2) | Snapshot do custo |
| created_at | TIMESTAMPTZ | Data de criação |

**Relacionamentos**:
- `receita_id` → `receitas.id` (CASCADE)
- `insumo_id` → `insumos.id` (CASCADE)

**Constraints**:
- UNIQUE(receita_id, insumo_id)

**Índices**:
- `idx_receita_insumos_receita` (receita_id)
- `idx_receita_insumos_insumo` (insumo_id)

---

### 7. `precos_marketplace`
Preços específicos de produtos por marketplace.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| produto_id | BIGINT | FK para produtos |
| marketplace_id | BIGINT | FK para marketplaces |
| preco | DECIMAL(10,2) | Preço no marketplace |
| margem_lucro | DECIMAL(5,2) | Margem de lucro % |
| ativo | BOOLEAN | Se está ativo |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

**Relacionamentos**:
- `produto_id` → `produtos.id` (CASCADE)
- `marketplace_id` → `marketplaces.id` (CASCADE)

**Constraints**:
- UNIQUE(produto_id, marketplace_id)

**Índices**:
- `idx_precos_produto` (produto_id)
- `idx_precos_marketplace` (marketplace_id)

---

### 8. `pedidos`
Pedidos realizados pelos clientes.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| numero_pedido | TEXT | Número único do pedido |
| marketplace_id | BIGINT | FK para marketplaces |
| cliente_nome | TEXT | Nome do cliente |
| cliente_telefone | TEXT | Telefone |
| cliente_endereco | TEXT | Endereço |
| status | TEXT | 'pendente', 'em_preparo', 'pronto', 'entregue', 'cancelado' |
| valor_subtotal | DECIMAL(10,2) | Subtotal |
| valor_desconto | DECIMAL(10,2) | Desconto |
| valor_taxa_entrega | DECIMAL(10,2) | Taxa de entrega |
| valor_total | DECIMAL(10,2) | Total |
| metodo_pagamento | TEXT | Método de pagamento |
| observacoes | TEXT | Observações |
| data_pedido | TIMESTAMPTZ | Data do pedido |
| data_entrega | TIMESTAMPTZ | Data de entrega |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

**Relacionamentos**:
- `marketplace_id` → `marketplaces.id`

**Constraints**:
- UNIQUE(numero_pedido)

**Índices**:
- `idx_pedidos_status` (status)
- `idx_pedidos_marketplace` (marketplace_id)
- `idx_pedidos_data` (data_pedido)

---

### 9. `pedido_itens`
Itens individuais de cada pedido.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| pedido_id | BIGINT | FK para pedidos |
| produto_id | BIGINT | FK para produtos |
| produto_nome | TEXT | Snapshot do nome |
| quantidade | INTEGER | Quantidade |
| preco_unitario | DECIMAL(10,2) | Preço unitário |
| preco_total | DECIMAL(10,2) | Total do item |
| observacoes | TEXT | Observações |
| created_at | TIMESTAMPTZ | Data de criação |

**Relacionamentos**:
- `pedido_id` → `pedidos.id` (CASCADE)
- `produto_id` → `produtos.id`

**Índices**:
- `idx_pedido_itens_pedido` (pedido_id)
- `idx_pedido_itens_produto` (produto_id)

---

### 10. `producao`
Registro de lotes de produção.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| receita_id | BIGINT | FK para receitas |
| produto_id | BIGINT | FK para produtos |
| quantidade_produzida | INTEGER | Unidades produzidas |
| data_producao | DATE | Data da produção |
| custo_total | DECIMAL(10,2) | Custo total |
| observacoes | TEXT | Observações |
| created_at | TIMESTAMPTZ | Data de criação |

**Relacionamentos**:
- `receita_id` → `receitas.id` (CASCADE)
- `produto_id` → `produtos.id`

**Índices**:
- `idx_producao_receita` (receita_id)
- `idx_producao_produto` (produto_id)
- `idx_producao_data` (data_producao)

---

### 11. `movimentacoes_estoque`
Histórico de movimentações de estoque.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| insumo_id | BIGINT | FK para insumos |
| tipo | TEXT | 'entrada', 'saida', 'ajuste', 'perda' |
| quantidade | DECIMAL(10,3) | Quantidade movimentada |
| estoque_anterior | DECIMAL(10,3) | Estoque antes |
| estoque_atual | DECIMAL(10,3) | Estoque depois |
| custo_unitario | DECIMAL(10,2) | Custo unitário |
| motivo | TEXT | Motivo da movimentação |
| referencia_tipo | TEXT | 'producao', 'compra', 'ajuste', 'perda' |
| referencia_id | BIGINT | ID da referência |
| usuario | TEXT | Usuário responsável |
| data_movimentacao | TIMESTAMPTZ | Data da movimentação |
| created_at | TIMESTAMPTZ | Data de criação |

**Relacionamentos**:
- `insumo_id` → `insumos.id` (CASCADE)

**Índices**:
- `idx_movimentacoes_insumo` (insumo_id)
- `idx_movimentacoes_tipo` (tipo)
- `idx_movimentacoes_data` (data_movimentacao)

---

### 12. `despesas`
Despesas operacionais do negócio.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| descricao | TEXT | Descrição da despesa |
| categoria_id | BIGINT | FK para categorias |
| valor | DECIMAL(10,2) | Valor |
| tipo | TEXT | 'fixa', 'variavel' |
| data_vencimento | DATE | Data de vencimento |
| data_pagamento | DATE | Data de pagamento |
| status | TEXT | 'pendente', 'paga', 'atrasada', 'cancelada' |
| recorrente | BOOLEAN | Se é recorrente |
| observacoes | TEXT | Observações |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

**Relacionamentos**:
- `categoria_id` → `categorias.id`

**Índices**:
- `idx_despesas_categoria` (categoria_id)
- `idx_despesas_status` (status)
- `idx_despesas_data_vencimento` (data_vencimento)
- `idx_despesas_tipo` (tipo)

---

### 13. `equipamentos`
Equipamentos usados na produção.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| nome | TEXT | Nome do equipamento |
| descricao | TEXT | Descrição |
| valor_compra | DECIMAL(10,2) | Valor de compra |
| data_compra | DATE | Data de compra |
| vida_util_meses | INTEGER | Vida útil em meses |
| depreciacao_mensal | DECIMAL(10,2) | Depreciação mensal |
| imagem_url | TEXT | URL da imagem |
| status | TEXT | 'ativo', 'manutencao', 'inativo' |
| observacoes | TEXT | Observações |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

**Índices**:
- `idx_equipamentos_status` (status)

---

### 14. `chaves_pix`
Chaves PIX para recebimento.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| tipo | TEXT | 'cpf', 'cnpj', 'email', 'telefone', 'aleatoria' |
| chave | TEXT | Chave PIX |
| nome_titular | TEXT | Nome do titular |
| principal | BOOLEAN | Se é a chave principal |
| ativo | BOOLEAN | Se está ativa |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

**Constraints**:
- UNIQUE(chave)

**Índices**:
- `idx_chaves_pix_principal` (principal) WHERE principal = true
- `idx_chaves_pix_ativo` (ativo)

---

### 15. `configuracoes`
Configurações gerais do sistema.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | Chave primária |
| chave | TEXT | Chave da configuração |
| valor | TEXT | Valor |
| tipo | TEXT | 'string', 'number', 'boolean', 'json' |
| descricao | TEXT | Descrição |
| categoria | TEXT | Categoria da config |
| created_at | TIMESTAMPTZ | Data de criação |
| updated_at | TIMESTAMPTZ | Data de atualização |

**Constraints**:
- UNIQUE(chave)

**Índices**:
- `idx_configuracoes_chave` (chave)
- `idx_configuracoes_categoria` (categoria)

---

## 🔐 Segurança (Row Level Security)

Todas as tabelas têm **Row Level Security (RLS)** habilitado com a seguinte política padrão:

```sql
CREATE POLICY "Permitir tudo para usuários autenticados" 
ON <tabela> FOR ALL USING (auth.uid() IS NOT NULL);
```

Isso significa que apenas usuários autenticados podem acessar os dados.

---

## 🔄 Triggers

Todas as tabelas com campo `updated_at` têm um trigger que atualiza automaticamente este campo quando um registro é modificado:

```sql
CREATE TRIGGER update_<tabela>_updated_at 
BEFORE UPDATE ON <tabela> 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

## 📊 Diagrama de Relacionamentos

```
categorias
├── marketplaces
├── insumos
│   └── receita_insumos ←→ receitas
├── produtos
│   ├── receitas
│   ├── precos_marketplace ← marketplaces
│   ├── pedido_itens
│   └── producao ← receitas
├── pedidos
│   ├── marketplaces
│   └── pedido_itens → produtos
└── despesas

Standalone: equipamentos, chaves_pix, configuracoes, movimentacoes_estoque
```

---

## 📝 Dados Iniciais

O schema inclui dados iniciais (seed data):

### Categorias (16 registros)
- 4 de produtos (Cremoso, Frutas, Chocolate, Gourmet)
- 3 de marketplace (Delivery, Loja Física, WhatsApp)
- 3 de insumos (Ingredientes, Embalagens, Equipamentos)
- 4 de despesas (Aluguel, Marketing, Manutenção, Salários)

### Marketplaces (4 registros)
- iFood (27% taxa)
- Rappi (25% taxa)
- WhatsApp (3.5% taxa)
- Loja Física (0% taxa)

### Configurações (4 registros)
- moeda: BRL
- timezone: America/Sao_Paulo
- margem_lucro_padrao: 30%
- custo_mao_obra_hora: R$ 15,00

---

## 🚀 Próximos Passos

Após criar as tabelas:

1. ✅ Verificar se todas foram criadas em **Table Editor**
2. ✅ Testar inserção de dados com o exemplo em `exemplo-categorias-supabase.html`
3. ✅ Configurar regras de RLS mais específicas se necessário
4. ✅ Criar índices adicionais conforme necessidade
5. ✅ Implementar backups automáticos

---

**Documentação criada em**: 2026-02-08  
**Versão do Schema**: 1.0  
**Banco de Dados**: PostgreSQL 15+ (Supabase)
