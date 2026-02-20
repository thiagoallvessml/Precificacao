# Debug: Logs em Vendas - Preços de Precificação

## 🔍 Logs Adicionados

Foram adicionados logs detalhados em `vendas.html` para debugar o carregamento de preços.

---

## 📋 Como Usar

### **1. Abra o Console do Navegador**

1. Acesse `vendas.html`
2. Pressione **F12** ou **Ctrl+Shift+I**
3. Vá na aba **Console**

---

### **2. Recarregue a Página**

Pressione **Ctrl+R** ou **F5**

Você verá os seguintes logs:

---

## 📊 Logs Exibidos

### **A. Carregamento de Marketplaces**
```
📦 Marketplaces carregados: Array(2)
  0: {id: 123, nome: "iFood", tipo: "marketplace", ...}
  1: {id: 124, nome: "WhatsApp", tipo: "marketplace", ...}
```

**Verificar:**
- ✅ Marketplaces foram carregados?
- ✅ Têm `tipo: "marketplace"`?
- ✅ `ativo: true`?

---

### **B. Preços RAW do Banco**
```
💰 Preços RAW do banco: Array(5)
  0: {id: 1, produto_id: 10, categoria_marketplace_id: 123, preco: "12.50"}
  1: {id: 2, produto_id: 11, categoria_marketplace_id: 123, preco: "8.00"}
  ...
```

**Verificar:**
- ✅ Preços foram carregados?
- ✅ Campo é `categoria_marketplace_id` ou `marketplace_id`?
- ✅ IDs batem com produtos e marketplaces?

---

### **C. Processamento Individual**
```
💵 Preço configurado: Produto 10 | Marketplace 123 | R$ 12.50
💵 Preço configurado: Produto 11 | Marketplace 123 | R$ 8.00
```

**Verificar:**
- ✅ Cada preço está sendo processado?
- ✅ IDs estão corretos?

---

### **D. Objeto Final de Preços**
```
🗂️ Objeto precosMarketplace final: 
{
  10: { 123: "12.50", 124: "10.00" },
  11: { 123: "8.00" }
}
```

**Estrutura:**
```javascript
{
  [produto_id]: {
    [marketplace_id]: preco
  }
}
```

**Verificar:**
- ✅ Objeto está bem formado?
- ✅ IDs de produtos existem?
- ✅ IDs de marketplaces existem?

---

### **E. Renderização de Cada Produto**
```
🔍 Renderizando produto: Ninho com Nutella (ID: 10)
   Marketplace selecionado: 123
   Preços disponíveis para este produto: {123: "12.50", 124: "10.00"}
   ✅ PREÇO ENCONTRADO: R$ 12.50
```

**OU, se não encontrar:**
```
🔍 Renderizando produto: Geladinho Morango (ID: 11)
   Marketplace selecionado: 123
   Preços disponíveis para este produto: undefined
   ❌ SEM PREÇO para marketplace 123
   Verificação:
      - marketplaceSelecionado existe? true
      - precosMarketplace[11] existe? false
      - precosMarketplace[11][123] existe? false
```

---

## 🐛 Diagnósticos Comuns

### **Problema 1: Preços RAW está vazio**
```
💰 Preços RAW do banco: []
```

**Causa:** Nenhum preço cadastrado no banco

**Solução:** Configure preços em `precificacao.html`

---

### **Problema 2: Campo errado no banco**
```
💰 Preços RAW do banco: Array(1)
  0: {marketplace_id: 123, ...}  ← Deveria ser categoria_marketplace_id
```

**Causa:** Tabela ainda usa `marketplace_id`

**Solução:** Execute `fix-marketplace-rapido.sql`

---

### **Problema 3: IDs não batem**
```
💵 Preço configurado: Produto 10 | Marketplace 999 | R$ 12.50
📦 Marketplaces carregados: [{id: 123, ...}]
```

**Causa:** `categoria_marketplace_id` não existe nas categorias

**Solução:** Reconfigure os preços com IDs corretos

---

### **Problema 4: Produto sem objeto**
```
🔍 Renderizando produto: Ninho (ID: 10)
   Preços disponíveis para este produto: undefined
```

**Causa:** Nenhum preço configurado para este produto

**Solução:** Configure em `precificacao.html`

---

### **Problema 5: Marketplace ID errado**
```
🔍 Renderizando produto: Ninho (ID: 10)
   Marketplace selecionado: 123
   Preços disponíveis para este produto: {124: "12.50"}
```

**Causa:** Preço existe, mas para marketplace diferente (124 ≠ 123)

**Solução:** Configure preço para o marketplace correto

---

## ✅ Fluxo Esperado (Tudo Funcionando)

```
📦 Marketplaces carregados: [iFood, WhatsApp]
💰 Preços RAW do banco: [5 preços]
💵 Preço configurado: Produto 10 | Marketplace 123 | R$ 12.50
💵 Preço configurado: Produto 10 | Marketplace 124 | R$ 10.00
💵 Preço configurado: Produto 11 | Marketplace 123 | R$ 8.00
...
🗂️ Objeto precosMarketplace final: {...bem formado...}

🔍 Renderizando produto: Ninho (ID: 10)
   Marketplace selecionado: 123
   Preços disponíveis: {123: "12.50", 124: "10.00"}
   ✅ PREÇO ENCONTRADO: R$ 12.50

🔍 Renderizando produto: Morango (ID: 11)
   Marketplace selecionado: 123
   Preços disponíveis: {123: "8.00"}
   ✅ PREÇO ENCONTRADO: R$ 8.00
```

---

## 🔧 Próximos Passos

1. **Abra o console** (F12)
2. **Recarregue a página** (F5)
3. **Copie TODOS os logs** do console
4. **Analise** cada seção acima
5. **Identifique** onde está o problema

---

## 📸 Captura de Tela

Se precisar de ajuda, tire print do console mostrando:
- Marketplaces carregados
- Preços RAW
- Objeto final
- Renderização de um produto

Isso vai mostrar exatamente onde está o problema! 🎯
