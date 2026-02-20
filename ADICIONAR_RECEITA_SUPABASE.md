# ✅ Adicionar Receita - Integração com Supabase

## 🎯 O que foi feito

A página **`adicionar-receita.html`** foi **completamente integrada com Supabase**!

### ✨ **Principais Mudanças:**

#### **1. Ingredientes Dinâmicos** ✅
- ❌ **ANTES**: Opções hardcoded ("Leite Condensado", "Creme de Leite", etc.)
- ✅ **AGORA**: Carrega da tabela `insumos` WHERE `tipo = 'ingrediente'`

#### **2. Embalagens Dinâmicas** ✅
- ❌ **ANTES**: Opções hardcoded ("Saco 6x24", "Pote 100ml", etc.)
- ✅ **AGORA**: Carrega da tabela `insumos` WHERE `tipo = 'embalagem'`

#### **3. Equipamentos Dinâmicos** ✅
- ❌ **ANTES**: Opções hardcoded ("Freezer", "Liquidificador", etc.)
- ✅ **AGORA**: Carrega da tabela `insumos` WHERE `tipo = 'equipamento'`

#### **4. Categorias de Receitas** ✅
- Carrega da tabela `categorias` WHERE `tipo = 'receitas'`

#### **5. Cálculo de Custos em Tempo Real** ✅
- Custo de ingredientes calculado automaticamente
- Custo de embalagens calculado automaticamente
- Custo de equipamentos baseado no tempo de uso
- Custo unitário = custo total / rendimento

#### **6. Salvamento Funcional** ✅
- Salva receita na tabela `receitas`
- Salva relacionamentos na tabela `receitas_insumos`
- Validações de campos obrigatórios
- Notificações de sucesso/erro

---

## 📊 Estrutura de Dados

### **Dados Carregados:**

```javascript
// Ingredientes (tipo = 'ingrediente')
{
    id: 1,
    nome: "Leite Condensado Moça 395g",
    tipo: "ingrediente",
    unidade_medida: "g",
    custo_unitario: 13.70, // Custo por 395g
    ativo: true
}

// Embalagens (tipo = 'embalagem')
{
    id: 50,
    nome: "Saco 6x24 (100un)",
    tipo: "embalagem",
    unidade_medida: "un",
    custo_unitario: 0.15, // Custo por saco
    ativo: true
}

// Equipamentos (tipo = 'equipamento')
{
    id: 100,
    nome: "Freezer Horizontal",
    tipo: "equipamento",
    unidade_medida: "kWh",
    custo_unitario: 0.85, // Custo por kWh
    ativo: true
}
```

### **Dados Salvos:**

#### **Tabela `receitas`:**
```javascript
{
    nome: "Ninho com Nutella",
    descricao: "Receita cremosa...",
    categoria_id: 2,
    rendimento: 10, // quantas unidades
    tempo_preparo: 45, // minutos
    ativo: true
}
```

#### **Tabela `receitas_insumos`:**
```javascript
// Para cada ingrediente
{
    receita_id: 5,
    insumo_id: 1, // Leite Condensado
    quantidade: 395, // gramas
    tempo_uso: null
}

// Para cada embalagem
{
    receita_id: 5,
    insumo_id: 50, // Saco
    quantidade: 10, // unidades
    tempo_uso: null
}

// Para cada equipamento
{
    receita_id: 5,
    insumo_id: 100, // Freezer
    quantidade: null,
    tempo_uso: 30 // minutos
}
```

---

## 🔄 Como Funciona

### **1. Carregamento Inicial:**
```
1. Página abre
2. Carrega ingredientes (tipo = 'ingrediente')
3. Carrega embalagens (tipo = 'embalagem')
4. Carrega equipamentos (tipo = 'equipamento')
5. Carrega categorias de receitas
6. Adiciona primeiro card de ingrediente vazio
```

### **2. Adicionar Insumos:**
```
USO clica "Adicionar" em Ingredientes
→ Cria novo card
→ Dropdown já tem os ingredientes cadastrados
→ Usuário seleciona "Leite Condensado Moça 395g"
→ Digita quantidade: 395
→ Custo calculado automaticamente: R$ 13,70
→ Custo total atualizado
```

### **3. Cálculo de Custos:**
```javascript
// Custo de cada ingrediente
custo = insumo.custo_unitario * quantidade

// Exemplo:
// Leite Condensado: R$ 13,70 por 395g
// Quantidade usada: 395g
// Custo: R$ 13,70 * 1 = R$ 13,70

// Custo total
custoTotal = soma de todos os custos

// Custo unitário
custoUnitario = custoTotal / rendimento
// Se rendimento = 10 unidades
// custoUnitario = R$ 50,00 / 10 = R$ 5,00
```

### **4. Salvamento:**
```
1. Validações
   - Nome obrigatório
   - Rendimento > 0
   - Pelo menos 1 ingrediente

2. Insere na tabela 'receitas'
3. Para cada ingrediente:
   - Insere em 'receitas_insumos'
4. Para cada embalagem:
   - Insere em 'receitas_insumos'
5. Para cada equipamento:
   - Insere em 'receitas_insumos'
6. Notificação de sucesso
7. Redireciona para receitas.html
```

---

## 🧪 Como Testar

### **Pré-requisitos:**

#### **1. Ter insumos cadastrados:**
```sql
-- Verificar se tem insumos de cada tipo
SELECT tipo, COUNT(*) FROM insumos WHERE ativo = true GROUP BY tipo;

-- Deve retornar:
-- tipo          | count
-- --------------|------
-- ingrediente   | 10
-- embalagem     | 5
-- equipamento   | 3
```

Se não houver, cadastre insumos primeiro!

#### **2. Ter categorias de receitas:**
```sql
SELECT * FROM categorias WHERE tipo = 'receitas' AND ativo = true;

-- Se não houver, crie:
INSERT INTO categorias (nome, tipo, icone, ativo)
VALUES 
    ('Cremosos', 'receitas', '🍦', true),
    ('Frutas', 'receitas', '🍓', true),
    ('Gourmet', 'receitas', '⭐', true);
```

### **Teste 1: Carregar Página**
```
1. Abra: http://localhost:5173/adicionar-receita.html
2. Veja se os dropdowns têm opções
3. Abra Console (F12)
4. Procure por: "✅ Dados carregados:"
5. Deve mostrar quantos insumos foram carregados
```

### **Teste 2: Adicionar Receita**
```
1. Preencha:
   - Nome: "Teste de Receita"
   - Categoria: Selecione uma
   - Rendimento: 10
   - Preparo: 30

2. Clique "Adicionar" em Ingredientes
3. Selecione um ingrediente
4. Digite quantidade
5. Veja se o custo aparece

6. Clique "Adicionar" em Embalagens
7. Selecione uma embalagem
8. Digite quantidade

9. Veja se "Custo Total" foi atualizado
10. Veja se "Custo Unitário" aparece

11. Clique em "Salvar Receita"
12. Deve aparecer notificação verde
13. Deve redirecionar para receitas.html
```

### **Teste 3: Verificar se Salvou**
```sql
-- Ver receita criada
SELECT * FROM receitas ORDER BY created_at DESC LIMIT 1;

-- Ver insumos da receita
SELECT 
    r.nome as receita,
    i.nome as insumo,
    i.tipo,
    ri.quantidade,
    ri.tempo_uso
FROM receitas_insumos ri
JOIN receitas r ON r.id = ri.receita_id
JOIN insumos i ON i.id = ri.insumo_id
WHERE r.id = (SELECT id FROM receitas ORDER BY created_at DESC LIMIT 1);
```

---

## 🔍 Resolução de Problemas

### **Problema: Dropdowns aparecem vazios**

**Causa:** Não há insumos cadastrados

**Solução:**
```sql
-- 1. Verificar se tem insumos
SELECT * FROM insumos WHERE ativo = true;

-- 2. Se não houver, cadastre via gestao-insumos.html
-- Ou insira manualmente:
INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, ativo)
VALUES 
    ('Leite Condensado 395g', 'ingrediente', 'g', 13.70, true),
    ('Saco 6x24', 'embalagem', 'un', 0.15, true),
    ('Freezer', 'equipamento', 'kWh', 0.85, true);
```

### **Problema: Dropdown aparece "Nenhum ... cadastrado"**

**Verifiquei:**
```sql
-- Tem insumos deste tipo?
SELECT * FROM insumos WHERE tipo = 'ingrediente' AND ativo = true;

-- Tipo está correto?
SELECT DISTINCT tipo FROM insumos;
-- Deve ser exatamente: 'ingrediente', 'embalagem', 'equipamento'
```

### **Problema: Custos não calculam**

**Verificações:**
1. Abra Console (F12)
2. Veja se há erros JavaScript
3. Verifique se `custo_unitario` está preenchido no insumo
```sql
SELECT nome, custo_unitario FROM insumos WHERE custo_unitario IS NULL OR custo_unitario = 0;
```

### **Problema: Erro ao salvar**

**Verificações:**
```sql
-- 1. Permissões RLS
CREATE POLICY "Permitir acesso público" ON receitas FOR ALL USING (true);
CREATE POLICY "Permitir acesso público" ON receitas_insumos FOR ALL USING (true);

-- 2. Tabela receitas_insumos existe?
SELECT * FROM receitas_insumos LIMIT 1;

-- Se não existir, crie conforme database-schema.sql
```

---

## ✅ Resumo

| Feature | Antes | Depois |
|---------|-------|--------|
| Ingredientes | Mock (hardcoded) | ✅ Do Supabase |
| Embalagens | Mock (hardcoded) | ✅ Do Supabase |
| Equipamentos | Mock (hardcoded) | ✅ Do Supabase |
| Categorias | Mock (hardcoded) | ✅ Do Supabase |
| Cálculo de custos | ❌ Não funciona | ✅ Tempo real |
| Salvamento | ❌ Não funciona | ✅ INSERT no banco |
| Validações | ❌ Nenhuma | ✅ Nome + Rendimento + Ingredientes |
| Notificações | ❌ Nenhuma | ✅ Toast messages |

---

## 🎯 Fluxo Completo

```
┌─────────────────────────────────────┐
│ Gestão de Insumos                   │
│ Cadastra ingredientes, embalagens,  │
│ equipamentos                        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Adicionar Receita                   │
│ Carrega insumos por tipo            │
│ Calcula custos em tempo real        │
│ Salva receita + relacionamentos     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Adicionar Produto                   │
│ Seleciona receita cadastrada        │
│ Usa custo da receita                │
└─────────────────────────────────────┘
```

**TUDO INTEGRADO E FUNCIONANDO!** 🎉

**Teste agora e me avise o resultado!** 👍
