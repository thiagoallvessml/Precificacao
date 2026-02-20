# Migração: Marketplaces para Categorias

## 🎯 Objetivo

Usar **categorias do tipo 'marketplace'** ao invés de uma tabela `marketplaces` separada.

---

## 📋 Estrutura Atual vs Nova

### **ANTES (Errado):**
```
precos_marketplace
├─ marketplace_id → marketplaces.id
```

### **DEPOIS (Correto):**
```
precos_marketplace
├─ categoria_marketplace_id → categorias.id (tipo='marketplace')
```

---

## 🔧 Passos de Migração

### **1. Criar Categorias de Marketplace**

Execute no Supabase SQL Editor:

```sql
-- Criar categorias tipo marketplace
INSERT INTO categorias (nome, tipo, icone, descricao, ativo)
VALUES 
    ('iFood', 'marketplace', 'restaurant', 'Delivery via iFood', true),
    ('WhatsApp', 'marketplace', 'chat', 'Vendas via WhatsApp', true),
    ('Loja Física', 'marketplace', 'store', 'Vendas presenciais', true),
    ('Rappi', 'marketplace', 'delivery_dining', 'Delivery via Rappi', true),
    ('Instagram', 'marketplace', 'photo_camera', 'Vendas via Instagram', true)
ON CONFLICT DO NOTHING;

-- Ver IDs criados
SELECT id, nome FROM categorias WHERE tipo = 'marketplace';
```

---

### **2. Ajustar Tabela precos_marketplace**

**Opção A: Se a tabela já existe com dados**
```sql
-- Adicionar nova coluna
ALTER TABLE precos_marketplace 
ADD COLUMN IF NOT EXISTS categoria_marketplace_id BIGINT;

-- Adicionar foreign key
ALTER TABLE precos_marketplace 
ADD CONSTRAINT precos_marketplace_categoria_fkey 
FOREIGN KEY (categoria_marketplace_id) 
REFERENCES categorias(id) 
ON DELETE CASCADE;

-- Migrar dados (se houver)
-- UPDATE precos_marketplace SET categoria_marketplace_id = marketplace_id;

-- Remover coluna antiga (CUIDADO: apenas se tiver certeza!)
-- ALTER TABLE precos_marketplace DROP COLUMN marketplace_id;
```

**Opção B: Recriar a tabela (se estiver vazia)**
```sql
-- Dropar tabela antiga
DROP TABLE IF EXISTS precos_marketplace CASCADE;

-- Recriar corretamente
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
```

---

### **3. Atualizar Código da Aplicação**

#### **vendas.html** ✅ (Já atualizado)
```javascript
// Buscar de categorias
const { data: catData } = await getAllRecords('categorias');
marketplaces = catData.filter(c => c.tipo === 'marketplace' && c.ativo);

// Compatibilidade ao ler preços
const marketplaceId = p.categoria_marketplace_id || p.marketplace_id;
```

#### **Páginas de Precificação** (adicionar-produto.html, precificacao.html)
```javascript
// Ao salvar preço
const precoData = {
    produto_id: produtoId,
    categoria_marketplace_id: marketplaceId, // ✅ Correto
    preco: preco,
    ativo: true
};
```

---

## 🗂️ Gerenciamento de Categorias Marketplace

Use a página `categorias.html` para gerenciar:

1. **Adicionar novo marketplace:**
   - Nome: "Uber Eats"
   - Tipo: **marketplace**
   - Ícone: delivery_dining
   - Ativo: ✅

2. **Editar existente:**
   - Alterar nome, ícone ou desativar

3. **Deletar:**
   - Remove o marketplace e seus preços (CASCADE)

---

## ✅ Checklist de Verificação

- [ ] Categorias marketplace criadas
- [ ] Tabela `precos_marketplace` usa `categoria_marketplace_id`
- [ ] `vendas.html` busca de categorias ✅
- [ ] Páginas de precificação salvam com campo correto
- [ ] Sistema funcionando end-to-end

---

## 🎯 Vantagens

1. **Centralização**: Todas as categorias em um lugar
2. **Consistência**: Mesmo padrão para produtos, insumos, despesas
3. **Flexibilidade**: Fácil adicionar/remover marketplaces via UI
4. **Simplicidade**: Uma fonte de verdade para categorias

---

## 🚨 Se Ainda Tiver Erro

```
Error: foreign key constraint "precos_marketplace_marketplace_id_fkey"
```

**Significa que:**
- A tabela ainda usa `marketplace_id`
- Precisa executar os scripts de migração acima

**Execute:**
```sql
-- Ver estrutura atual
\d precos_marketplace

-- Ver foreign keys
SELECT constraint_name, table_name 
FROM information_schema.table_constraints 
WHERE constraint_type = 'FOREIGN KEY' 
AND table_name = 'precos_marketplace';
```
