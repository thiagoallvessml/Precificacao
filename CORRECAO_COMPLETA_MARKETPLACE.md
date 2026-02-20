# ✅ CORREÇÃO FINAL: Sistema de Marketplaces

## 🔴 Problemas Encontrados:

1. ❌ `precos_marketplace` usava `marketplace_id` 
2. ❌ `pedidos` usava `marketplace_id`
3. ❌ Referenciavam tabela `marketplaces` que não existe

## ✅ Solução: Usar Categorias

Todo o sistema agora usa **categorias do tipo 'marketplace'**.

---

## 🔧 EXECUTE NO SUPABASE (Ordem Exata):

### **1. Corrigir Tabela precos_marketplace**
```sql
DROP TABLE IF EXISTS precos_marketplace CASCADE;

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

CREATE INDEX idx_precos_produto ON precos_marketplace(produto_id);
CREATE INDEX idx_precos_marketplace ON precos_marketplace(categoria_marketplace_id);

ALTER TABLE precos_marketplace ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso público precos" ON precos_marketplace FOR ALL USING (true) WITH CHECK (true);
```

---

### **2. Corrigir Tabela pedidos**
```sql
-- Dropar foreign key antiga
ALTER TABLE pedidos DROP CONSTRAINT IF EXISTS pedidos_marketplace_id_fkey;

-- Renomear coluna
ALTER TABLE pedidos RENAME COLUMN marketplace_id TO categoria_marketplace_id;

-- Adicionar nova foreign key
ALTER TABLE pedidos 
ADD CONSTRAINT pedidos_categoria_marketplace_fkey 
FOREIGN KEY (categoria_marketplace_id) 
REFERENCES categorias(id) 
ON DELETE SET NULL;
```

---

### **3. Verificar Estruturas**
```sql
-- Verificar precos_marketplace
SELECT column_name FROM information_schema.columns
WHERE table_name = 'precos_marketplace' AND column_name LIKE '%marketplace%';
-- Deve retornar: categoria_marketplace_id

-- Verificar pedidos
SELECT column_name FROM information_schema.columns
WHERE table_name = 'pedidos' AND column_name LIKE '%marketplace%';
-- Deve retornar: categoria_marketplace_id
```

---

## 📋 Arquivos de Código Atualizados:

### **1. precificacao.html** ✅
```javascript
// Linha 226, 308, 318
categoria_marketplace_id: marketplaceSelecionado
```

### **2. vendas.html** ✅
```javascript
// Linha 128-147: Carrega de categorias
marketplaces = catData.filter(c => c.tipo === 'marketplace');

// Linha 360: Salva pedido
categoria_marketplace_id: marketplaceSelecionado
```

---

## 🎯 Criar Categorias Marketplace

Se não tiver categorias ainda:
```sql
INSERT INTO categorias (nome, tipo, icone, descricao, ativo)
VALUES 
    ('iFood', 'marketplace', 'restaurant', 'Delivery via iFood', true),
    ('WhatsApp', 'marketplace', 'chat', 'Vendas via WhatsApp', true),
    ('Loja Física', 'marketplace', 'store', 'Vendas presenciais', true)
ON CONFLICT DO NOTHING;

-- Ver IDs criados
SELECT id, nome, tipo FROM categorias WHERE tipo = 'marketplace';
```

**Anote os IDs!** Você vai usar em precificação.

---

## 🔄 Configurar Preços

1. Acesse `precificacao.html`
2. Selecione marketplace (categoria)
3. Configure preços
4. Salve

---

## ✅ Testar Venda

1. Acesse `vendas.html`
2. Selecione marketplace
3. Adicione produtos (com preços configurados)
4. Finalize venda

**Deve funcionar sem erros!** 🎉

---

## 📊 Verificar Dados

```sql
-- Ver preços configurados
SELECT 
    p.nome as produto,
    c.nome as marketplace,
    pm.preco
FROM precos_marketplace pm
JOIN produtos p ON pm.produto_id = p.id
JOIN categorias c ON pm.categoria_marketplace_id = c.id
ORDER BY p.nome, c.nome;

-- Ver pedidos salvos
SELECT 
    ped.numero_pedido,
    c.nome as marketplace,
    ped.valor_total,
    ped.status
FROM pedidos ped
LEFT JOIN categorias c ON ped.categoria_marketplace_id = c.id
ORDER BY ped.created_at DESC
LIMIT 10;
```

---

## 🐛 Troubleshooting

### **Erro: "column categoria_marketplace_id does not exist"**
Execute os scripts SQL acima para criar/renomear colunas.

### **Erro: "foreign key constraint"**
Certifique-se que as categorias existem:
```sql
SELECT id, nome FROM categorias WHERE tipo = 'marketplace';
```

### **Preços não aparecem em vendas**
1. Verifique console (F12)
2. Veja logs:
   - `💰 Preços RAW do banco:` deve ter dados
   - `✅ PREÇO ENCONTRADO` deve aparecer

---

## ✅ Checklist Final

- [ ] Tabela `precos_marketplace` com `categoria_marketplace_id`
- [ ] Tabela `pedidos` com `categoria_marketplace_id`
- [ ] Categorias marketplace criadas
- [ ] RLS configurado
- [ ] `precificacao.html` salva corretamente
- [ ] `vendas.html` carrega e exibe preços
- [ ] Finalização de venda funciona
- [ ] Pedidos são salvos no banco

---

## 🚀 Atalho: Script Completo

Copie e cole TUDO no Supabase SQL Editor:

```sql
-- 1. Recriar precos_marketplace
DROP TABLE IF EXISTS precos_marketplace CASCADE;
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
CREATE INDEX idx_precos_produto ON precos_marketplace(produto_id);
CREATE INDEX idx_precos_marketplace ON precos_marketplace(categoria_marketplace_id);
ALTER TABLE precos_marketplace ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acesso público precos" ON precos_marketplace FOR ALL USING (true) WITH CHECK (true);

-- 2. Corrigir pedidos
ALTER TABLE pedidos DROP CONSTRAINT IF EXISTS pedidos_marketplace_id_fkey;
ALTER TABLE pedidos RENAME COLUMN marketplace_id TO categoria_marketplace_id;
ALTER TABLE pedidos ADD CONSTRAINT pedidos_categoria_marketplace_fkey 
FOREIGN KEY (categoria_marketplace_id) REFERENCES categorias(id) ON DELETE SET NULL;

-- 3. Criar categorias
INSERT INTO categorias (nome, tipo, icone, ativo)
VALUES 
    ('iFood', 'marketplace', 'restaurant', true),
    ('WhatsApp', 'marketplace', 'chat', true),
    ('Loja Física', 'marketplace', 'store', true)
ON CONFLICT DO NOTHING;

-- 4. Verificar
SELECT 'Categorias Marketplace:' as info, id, nome FROM categorias WHERE tipo = 'marketplace';
```

Execute e está pronto! ✅
