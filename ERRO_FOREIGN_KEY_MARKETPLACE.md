# Erro de Foreign Key em precos_marketplace

## 🐛 Problema

```
Error: insert or update on table "precos_marketplace" violates foreign key constraint "precos_marketplace_marketplace_id_fkey"
```

## 🔍 Causa

Este erro ocorre quando você tenta salvar um preço para um **marketplace_id** que não existe na tabela `marketplaces`.

### Cenário Comum:
1. Você acessa "Adicionar Produto" → aba "Precificação"
2. Tenta configurar preços por marketplace
3. O sistema tenta salvar com um `marketplace_id` que não está cadastrado

---

## ✅ Solução

### **Passo 1: Diagnosticar**

Execute o script `diagnostico-marketplaces.sql` no Supabase SQL Editor para verificar:
- Quais marketplaces existem
- Se há preços órfãos (sem marketplace correspondente)

```sql
-- Ver todos os marketplaces
SELECT id, nome, ativo FROM marketplaces ORDER BY id;
```

---

### **Passo 2: Criar Marketplaces**

Se não houver marketplaces cadastrados, execute o script `inserir-marketplaces-basicos.sql`:

```sql
-- Criar marketplaces padrão
INSERT INTO marketplaces (nome, taxa_operacional, icone, descricao, ativo, cor)
VALUES 
    ('iFood', 27.00, 'restaurant', 'Delivery via iFood', true, '#EA1D2C'),
    ('WhatsApp', 0.00, 'chat', 'Vendas via WhatsApp', true, '#25D366'),
    ('Loja Física', 0.00, 'store', 'Vendas presenciais', true, '#6366F1');
```

---

### **Passo 3: Verificar IDs**

Após criar os marketplaces, anote os IDs gerados:

```sql
SELECT id, nome FROM marketplaces ORDER BY id;
```

**Resultado esperado:**
```
id | nome
---|----------------
1  | iFood
2  | WhatsApp
3  | Loja Física
```

---

### **Passo 4: Usar na Aplicação**

Agora você pode configurar preços normalmente em "Adicionar Produto" → "Precificação".

O sistema irá:
1. Buscar os marketplaces disponíveis
2. Exibir campos para cada um
3. Salvar corretamente com os IDs correspondentes

---

## 🎯 Prevenção

### **Criar Marketplaces Pelo Sistema**

Você também pode criar marketplaces pela interface:

1. **Acesse:** Configurações → Marketplaces (ou crie esta página)
2. **Cadastre:** Nome, Taxa, Ícone, Cor
3. **Use:** Os IDs serão gerados automaticamente

---

## 📋 Estrutura da Tabela

```sql
CREATE TABLE marketplaces (
    id BIGSERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    taxa_operacional DECIMAL(5,2) DEFAULT 0.00,
    categoria_id BIGINT REFERENCES categorias(id),
    icone TEXT,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    cor TEXT
);

CREATE TABLE precos_marketplace (
    id BIGSERIAL PRIMARY KEY,
    produto_id BIGINT NOT NULL REFERENCES produtos(id),
    marketplace_id BIGINT NOT NULL REFERENCES marketplaces(id), -- ⚠️ DEVE EXISTIR!
    preco DECIMAL(10,2) NOT NULL,
    margem_lucro DECIMAL(5,2),
    ativo BOOLEAN DEFAULT true,
    UNIQUE(produto_id, marketplace_id)
);
```

---

## 🔧 Correção Rápida

Se você só quer testar rapidamente, execute:

```sql
-- Criar um marketplace simples
INSERT INTO marketplaces (nome, taxa_operacional, ativo)
VALUES ('Padrão', 0, true)
RETURNING id;

-- Use o ID retornado para configurar preços
```

---

## ⚠️ Importante

- Sempre verifique se o marketplace existe antes de salvar preços
- Use `SELECT id FROM marketplaces WHERE ativo = true` para listar IDs válidos
- O sistema de precificação depende de marketplaces cadastrados

---

## 🚀 Próximos Passos

Após resolver:
1. Configure marketplaces em "Adicionar Produto" → "Precificação"
2. Os preços aparecerão automaticamente em "Vendas"
3. Ao selecionar um marketplace, os preços corretos serão exibidos
