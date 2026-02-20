# Precificação por Marketplace em Vendas

## 📋 Como Funciona

A página de vendas (`vendas.html`) agora busca e exibe automaticamente os preços específicos cadastrados para cada marketplace na página de precificação.

## 🔄 Fluxo de Funcionamento

### **1. Carregamento de Dados**

Ao abrir a página de vendas, o sistema carrega:
```javascript
// Produtos disponíveis
produtos = await getAllRecords('produtos');

// Marketplaces ativos
marketplaces = await getAllRecords('marketplaces');

// Preços específicos por marketplace
precosMarketplace = await getAllRecords('precos_marketplace');
```

Os preços são organizados em um objeto:
```javascript
precosMarketplace = {
    1: { // produto_id
        10: 5.50, // marketplace_id: preco
        12: 6.00,
        15: 4.80
    },
    2: {
        10: 3.00
    }
}
```

---

### **2. Seleção de Marketplace**

Quando você seleciona um marketplace:
- ✅ Os preços de todos os produtos são atualizados automaticamente
- ✅ Os itens já no carrinho têm seus preços recalculados
- ✅ O total é atualizado com os novos valores

---

### **3. Exibição de Preços**

Para cada produto, o sistema:

1. **Verifica se existe preço específico** para o marketplace selecionado:
```javascript
if (marketplaceSelecionado && precosMarketplace[prod.id]?.[marketplaceSelecionado]) {
    preco = precosMarketplace[prod.id][marketplaceSelecionado];
} else {
    preco = prod.preco_base; // Fallback para preço base
}
```

2. **Exibe o label correto**:
   - "Preço Marketplace" - quando há preço específico
   - "Preço Base" - quando usa o preço padrão

---

### **4. Adicionar ao Carrinho**

Ao adicionar um produto:
- ✅ O preço correto (marketplace ou base) é salvo no carrinho
- ✅ Se trocar de marketplace, todos os preços são recalculados

---

## 🎯 Exemplo Prático

### **Cenário:**
- **Produto:** Geladinho de Morango (ID: 1)
- **Preço Base:** R$ 5,00
- **Preços por Marketplace:**
  - iFood (ID: 10): R$ 6,50
  - WhatsApp (ID: 12): R$ 5,50
  - Loja Física (ID: 15): R$ 4,50

### **Comportamento:**

**Marketplace: iFood**
```
Geladinho de Morango
R$ 6,50
Preço Marketplace
```

**Marketplace: WhatsApp**
```
Geladinho de Morango
R$ 5,50
Preço Marketplace
```

**Sem Marketplace/Não Configurado**
```
Geladinho de Morango
R$ 5,00
Preço Base
```

---

## 📝 Observações

1. **Fallback Automático**: Se um produto não tiver preço configurado para um marketplace específico, usa o preço base.

2. **Atualização Dinâmica**: Ao trocar de marketplace, todos os valores são recalculados automaticamente.

3. **Sincronização**: Os preços vêm da tabela `precos_marketplace`, configurada em `adicionar-produto.html` → aba "Precificação".

4. **Venda Registrada**: O pedido é salvo com o preço que estava ativo no momento da venda.
