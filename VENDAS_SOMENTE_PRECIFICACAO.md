# Vendas: Usar Apenas Preços de Precificação

## ✅ Alterações Implementadas

### **Problema Anterior:**
- Sistema usava `preco_base` como fallback
- Produtos sem precificação apareciam com preço base
- Permitia venda sem preço correto configurado

### **Solução Atual:**
- ✅ Usa **apenas** preços da tabela `precos_marketplace`
- ✅ Produtos sem preço ficam **bloqueados**
- ✅ Mostra mensagem clara: "Sem preço configurado"

---

## 🎯 Comportamento Novo

### **1. Exibição de Produtos**

**COM preço configurado:**
```
🍦 Geladinho Morango
R$ 6,50
Preço Marketplace
[- 0 +]  ← Botões habilitados
```

**SEM preço configurado:**
```
🍦 Geladinho Chocolate
⚠️ Sem preço configurado
Configure em Precificação
[🚫]  ← Botões bloqueados
```

---

### **2. Adicionar ao Carrinho**

```javascript
// Tenta adicionar produto sem preço
alterarQtd(produtoId, 1)
↓
❌ Alert: "Este produto não tem preço configurado para este marketplace!
Configure em: Adicionar Produto → Precificação"
```

---

### **3. Trocar Marketplace**

Ao selecionar outro marketplace:
1. ✅ **Tem preço** → Atualiza preço do item no carrinho
2. ❌ **Sem preço** → Remove item do carrinho automaticamente

```javascript
// Exemplo
Carrinho: [Morango (iFood=R$6.50), Chocolate (iFood=R$5.00)]
↓ Trocar para WhatsApp
↓
Carrinho: [Morango (WhatsApp=R$5.50)]
// Chocolate foi removido pois não tem preço para WhatsApp
```

---

## 📋 Código Modificado

### **renderProdutos()**
```javascript
// ANTES
let preco = parseFloat(prod.preco_base || 0);
if (marketplace) {
    preco = precosMarketplace[prod.id][marketplace] || preco;
}

// DEPOIS
let preco = null;
let temPreco = false;
if (marketplace && precosMarketplace[prod.id]?.[marketplace]) {
    preco = parseFloat(precosMarketplace[prod.id][marketplace]);
    temPreco = true;
}

// Botões condicionais
${temPreco ? '[- 0 +]' : '[🚫]'}
```

### **alterarQtd()**
```javascript
// ANTES
let preco = produto.preco_base;
if (marketplace) {
    preco = precosMarketplace[...] || preco;
}

// DEPOIS
if (!precosMarketplace[produtoId]?.[marketplace]) {
    alert('❌ Sem preço configurado!');
    return; // Não permite adicionar
}
const preco = precosMarketplace[produtoId][marketplace];
```

### **selecionarMarketplace()**
```javascript
// ANTES
Object.keys(carrinho).forEach(id => {
    carrinho[id].preco = novoPreco; // Sempre atualiza
});

// DEPOIS
Object.keys(carrinho).forEach(id => {
    if (precosMarketplace[id]?.[marketplace]) {
        carrinho[id].preco = novoPreco; // Atualiza
    } else {
        delete carrinho[id]; // Remove
    }
});
```

---

## 🎯 Fluxo Completo

1. **Abrir Vendas**
   - Selecionar marketplace (iFood, WhatsApp, etc)

2. **Ver Produtos**
   - ✅ Com preço → Pode adicionar
   - ❌ Sem preço → Bloqueado

3. **Adicionar ao Carrinho**
   - Apenas produtos com preço entram

4. **Trocar Marketplace**
   - Carrinho é limpo de itens sem preço

5. **Finalizar Venda**
   - Tudo salvo com preço correto!

---

## 📝 Pré-requisitos

Para um produto aparecer habilitado em Vendas:

1. ✅ Produto criado e `disponivel = true`
2. ✅ Preço configurado em **"Adicionar Produto" → Precificação**
3. ✅ Marketplace selecionado em Vendas

---

## 🚨 Mensagens ao Usuário

**Produto sem preço:**
```
❌ Sem preço configurado
Configure em Precificação
```

**Tentativa de adicionar:**
```
❌ Este produto não tem preço configurado para este marketplace!

Configure em: Adicionar Produto → Precificação
```

---

## ✅ Vantagens

1. **Precisão**: Apenas preços corretos são usados
2. **Segurança**: Não permite venda acidental sem preço
3. **Clareza**: Usuário sabe exatamente o que precisa fazer
4. **Integridade**: Dados financeiros sempre corretos
