# 🔴 PROBLEMA: Preços RAW do Banco Vazio

## 📊 Log Encontrado:
```
💰 Preços RAW do banco: []
```

## 🎯 Causa:
A tabela `precos_marketplace` está vazia. Possíveis razões:
1. Tabela não existe
2. Nenhum preço foi configurado
3. RLS bloqueando acesso
4. Estrutura da tabela incorreta

---

## ✅ SOLUÇÃO PASSO A PASSO

### **Passo 1: Verificar Estrutura**

Execute no Supabase SQL Editor:
```sql
-- Ver estrutura da tabela
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'precos_marketplace'
ORDER BY ordinal_position;
```

**Resultado Esperado:**
```
column_name                | data_type
---------------------------|----------
id                         | bigint
produto_id                 | bigint
categoria_marketplace_id   | bigint    ← CAMPO CORRETO!
preco                      | numeric
margem_lucro              | numeric
ativo                      | boolean
created_at                 | timestamp
updated_at                 | timestamp
```

**⚠️ Se aparecer `marketplace_id` ao invés de `categoria_marketplace_id`:**
- Execute: `fix-marketplace-rapido.sql`

---

### **Passo 2: Verificar RLS**

Execute:
```sql
-- Ver se RLS está ativo
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'precos_marketplace';
```

**Se `rowsecurity = true`**, execute:
```bash
fix-rls-precos-marketplace.sql
```

Isso vai criar políticas públicas permitindo acesso.

---

### **Passo 3: Verificar Dados Base**

Execute:
```sql
-- Ver produtos
SELECT id, nome FROM produtos WHERE disponivel = true;

-- Ver marketplaces (categorias)
SELECT id, nome FROM categorias WHERE tipo = 'marketplace';
```

**Anote os IDs**, você vai precisar deles!

**Exemplo:**
```
Produtos:
  1 - Ninho com Nutella
  2 - Geladinho Morango

Marketplaces:
  16 - iFood
  17 - WhatsApp
```

---

### **Passo 4: Inserir Preço Teste**

Execute no SQL:
```sql
-- Inserir preço de teste
-- Substitua os IDs pelos seus
INSERT INTO precos_marketplace (
    produto_id, 
    categoria_marketplace_id, 
    preco, 
    ativo
) VALUES 
    (1, 16, 12.50, true);  -- Ninho com Nutella no iFood por R$ 12,50

-- Verificar
SELECT * FROM precos_marketplace;
```

**Se der ERRO de foreign key:**
- Verifique se os IDs existem nas tabelas referenciadas

**Se der ERRO de permissão:**
- Execute `fix-rls-precos-marketplace.sql`

---

### **Passo 5: Testar em Vendas**

1. Recarregue `vendas.html` (F5)
2. Veja o console (F12)
3. Deve aparecer:
```
💰 Preços RAW do banco: Array(1)
  0: {produto_id: 1, categoria_marketplace_id: 16, preco: "12.50"}

🔍 Renderizando produto: Ninho com Nutella (ID: 1)
   ✅ PREÇO ENCONTRADO: R$ 12.50
```

---

### **Passo 6: Configurar Todos os Preços**

Após confirmar que funciona:

1. **Via SQL (Rápido):**
```sql
INSERT INTO precos_marketplace (produto_id, categoria_marketplace_id, preco, ativo)
VALUES 
    (1, 16, 12.50, true),  -- Ninho iFood
    (1, 17, 10.00, true),  -- Ninho WhatsApp
    (2, 16, 8.00, true),   -- Morango iFood
    (2, 17, 7.00, true);   -- Morango WhatsApp
```

2. **Via Interface (Recomendado):**
   - Acesse `precificacao.html`
   - Selecione marketplace
   - Configure preços
   - Clique "Salvar Alterações"

---

## 🐛 Troubleshooting

### **Erro: "violates foreign key constraint"**
```sql
-- Verificar se IDs existem
SELECT id, nome FROM produtos WHERE id = 1;
SELECT id, nome FROM categorias WHERE id = 16 AND tipo = 'marketplace';
```

### **Erro: "permission denied"**
Execute: `fix-rls-precos-marketplace.sql`

### **Tabela não existe**
Execute: `fix-marketplace-rapido.sql` (recria a tabela)

---

## 📋 Checklist

- [ ] Tabela `precos_marketplace` existe
- [ ] Campo é `categoria_marketplace_id` (não `marketplace_id`)
- [ ] RLS configurado (políticas públicas)
- [ ] Produtos cadastrados
- [ ] Categorias marketplace cadastradas
- [ ] Preço de teste inserido com sucesso
- [ ] `vendas.html` mostra preço no console
- [ ] Interface funciona corretamente

---

## 🚀 Atalho Rápido

**Para resolver TUDO de uma vez:**

1. Execute: `fix-marketplace-rapido.sql`
2. Execute: `fix-rls-precos-marketplace.sql`
3. Execute:
```sql
-- Inserir categorias marketplace
INSERT INTO categorias (nome, tipo, icone, ativo)
VALUES 
    ('iFood', 'marketplace', 'restaurant', true),
    ('WhatsApp', 'marketplace', 'chat', true)
ON CONFLICT DO NOTHING;

-- Ver IDs criados
SELECT id, nome FROM categorias WHERE tipo = 'marketplace';
```

4. Anote os IDs e configure preços em `precificacao.html`

Pronto! ✅
