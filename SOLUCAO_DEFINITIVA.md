# ✅ SOLUÇÃO DEFINITIVA: Recriar Tabela precos_marketplace

## 🔴 Erro Confirmado:
```
column pm.categoria_marketplace_id does not exist
```

**Causa:** Tabela usa `marketplace_id` (errado) ao invés de `categoria_marketplace_id` (correto)

---

## 🚀 EXECUTE AGORA (Ordem Exata):

### **PASSO 1: Recriar Tabela**
No **Supabase SQL Editor**, execute:
```bash
RECRIAR_PRECOS_MARKETPLACE.sql
```

Isso vai:
1. ✅ Dropar tabela antiga
2. ✅ Criar com estrutura correta (`categoria_marketplace_id`)
3. ✅ Configurar RLS
4. ✅ Criar índices
5. ✅ Mostrar estrutura final

**Resultado esperado:**
```
column_name              | data_type | is_nullable
-------------------------|-----------|------------
id                       | bigint    | NO
produto_id               | bigint    | NO
categoria_marketplace_id | bigint    | NO  ← CORRETO!
preco                    | numeric   | NO
margem_lucro            | numeric   | YES
ativo                    | boolean   | YES
created_at              | timestamp | YES
updated_at              | timestamp | YES
```

---

### **PASSO 2: Verificar IDs**
Execute:
```sql
-- Ver produtos
SELECT id, nome, preco_base FROM produtos WHERE disponivel = true;

-- Ver marketplaces
SELECT id, nome FROM categorias WHERE tipo = 'marketplace';
```

**Anote os IDs!** Exemplo:
```
Produto ID 1 = Ninho com Nutella
Categoria ID 16 = iFood
Categoria ID 17 = WhatsApp
```

---

### **PASSO 3: Inserir Preços de Teste**
Execute (ajuste os IDs!):
```sql
INSERT INTO precos_marketplace (
    produto_id, 
    categoria_marketplace_id, 
    preco, 
    ativo
) VALUES 
    (1, 16, 12.50, true),  -- Ninho no iFood
    (1, 17, 10.00, true);  -- Ninho no WhatsApp

-- Verificar
SELECT 
    pm.id,
    p.nome as produto,
    c.nome as marketplace,
    pm.preco
FROM precos_marketplace pm
JOIN produtos p ON pm.produto_id = p.id
JOIN categorias c ON pm.categoria_marketplace_id = c.id;
```

**Resultado esperado:**
```
id | produto            | marketplace | preco
---|--------------------|-----------|---------
1  | Ninho com Nutella  | iFood      | 12.50
2  | Ninho com Nutella  | WhatsApp   | 10.00
```

---

### **PASSO 4: Testar em Vendas**
1. Recarregue `vendas.html` (F5)
2. Abra console (F12)
3. Veja os logs:

```javascript
💰 Preços RAW do banco: Array(2)  ← Não vazio!
  0: {produto_id: 1, categoria_marketplace_id: 16, preco: "12.50"}
  1: {produto_id: 1, categoria_marketplace_id: 17, preco: "10.00"}

💵 Preço configurado: Produto 1 | Marketplace 16 | R$ 12.50
💵 Preço configurado: Produto 1 | Marketplace 17 | R$ 10.00

🔍 Renderizando produto: Ninho com Nutella (ID: 1)
   Marketplace selecionado: 16
   ✅ PREÇO ENCONTRADO: R$ 12.50  ← SUCESSO!
```

---

### **PASSO 5: Configurar Todos os Preços**

Agora pode usar a interface:
1. Acesse `precificacao.html`
2. Selecione marketplace
3. Configure preços
4. Clique "Salvar Alterações"

**Agora vai funcionar!** ✅

---

## 📋 Checklist Final:

- [ ] Executou `RECRIAR_PRECOS_MARKETPLACE.sql`
- [ ] Verificou estrutura (campo é `categoria_marketplace_id`)
- [ ] Anotou IDs de produtos e marketplaces
- [ ] Inseriu preço de teste
- [ ] Verificou que INSERT funcionou
- [ ] Recarregou `vendas.html`
- [ ] Console mostra `💰 Preços RAW do banco: Array(2)` (não vazio)
- [ ] Console mostra `✅ PREÇO ENCONTRADO`
- [ ] Interface mostra preço corretamente

---

## 🎯 Atalho Ultra-Rápido:

Copie e cole tudo de uma vez no Supabase SQL Editor:

```sql
-- 1. Recriar tabela
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

CREATE POLICY "Permitir leitura pública" ON precos_marketplace FOR SELECT USING (true);
CREATE POLICY "Permitir inserção pública" ON precos_marketplace FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir atualização pública" ON precos_marketplace FOR UPDATE USING (true);
CREATE POLICY "Permitir exclusão pública" ON precos_marketplace FOR DELETE USING (true);

-- 2. Ver IDs (anote!)
SELECT id, nome FROM produtos WHERE disponivel = true;
SELECT id, nome FROM categorias WHERE tipo = 'marketplace';

-- 3. Inserir teste (AJUSTE OS IDS!)
-- INSERT INTO precos_marketplace (produto_id, categoria_marketplace_id, preco, ativo)
-- VALUES (1, 16, 12.50, true);

-- 4. Verificar
-- SELECT * FROM precos_marketplace;
```

Execute e depois me diga o resultado! 🚀
