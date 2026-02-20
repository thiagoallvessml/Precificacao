# ✅ Correção: Status do Pedido

## 🔴 Erro:
```
new row for relation "pedidos" violates check constraint "pedidos_status_check"
```

## 🎯 Causa:
O código estava tentando salvar com `status: 'concluido'`, mas a constraint do banco permite apenas:

- `'pendente'`
- `'em_preparo'`
- `'pronto'`
- `'entregue'`
- `'cancelado'`

---

## ✅ Correção Aplicada:

### **vendas.html - linha 361**

```javascript
// ANTES (errado)
status: 'concluido',  ❌

// DEPOIS (correto)
status: 'entregue',  ✅
```

---

## 📋 Status Válidos para Pedidos:

| Status | Descrição | Uso |
|--------|-----------|-----|
| `pendente` | Pedido recebido | Inicial |
| `em_preparo` | Em produção | Processamento |
| `pronto` | Pronto para entrega | Aguardando |
| `entregue` | Entregue ao cliente | **Final (vendas.html)** |
| `cancelado` | Cancelado | Cancelamento |

---

## 🎯 Comportamento Atual:

Vendas manuais em `vendas.html` são salvas como **`entregue`** porque:
- ✅ Já foram concluídas
- ✅ Já foram pagas
- ✅ Já foram entregues (venda presencial/direta)

Se precisar de outro status, pode alterar conforme necessidade.

---

## 🔧 Customizar Status:

Se quiser salvar como `pendente` ou outro:

```javascript
// vendas.html linha 361
status: 'pendente',  // ou: em_preparo, pronto, entregue, cancelado
```

---

## ✅ Agora Funciona!

Tente finalizar a venda novamente. O pedido será salvo com sucesso! 🚀
