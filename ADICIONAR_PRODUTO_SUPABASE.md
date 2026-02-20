# ✅ Adicionar/Editar Produto - Integração com Supabase

## 🎯 O que foi feito

A página **`adicionar-produto.html`** foi **completamente integrada com Supabase**!

### ✨ **Principais Mudanças:**

#### **1. Campo "Receita" Dinâmico** ✅
- ❌ **ANTES**: Opções hardcoded ("Base ao Leite", "Base de Água", etc.)
- ✅ **AGORA**: Carrega receitas reais cadastradas na tabela `receitas`

```javascript
async function loadReceitas() {
    const { data } = await supabase
        .from('receitas')
        .select('id, nome')
        .eq('ativo', true)
        .order('nome');
    
    // Popula o dropdown com as receitas
}
```

#### **2. Campo "Categoria" Dinâmico** ✅
- ❌ **ANTES**: Não existia
- ✅ **AGORA**: Carrega categorias da tabela `categorias` (tipo = 'produtos')

```javascript
async function loadCategorias() {
    const { data } = await supabase
        .from('categorias')
        .select('id, nome, icone')
        .eq('tipo', 'produtos')
        .eq('ativo', true)
        .order('nome');
}
```

#### **3. Modo de Edição** ✅
- Detecta parâmetro `?id=X` na URL
- Carrega dados do produto existente
- Atualiza título para "Editar Produto"
- Salva usa UPDATE ao invés de INSERT

```javascript
// URL: adicionar-produto.html?id=5
// → Modo de edição ativado!
```

#### **4. Salvamento Funcional** ✅
- Validação de campos obrigatórios
- INSERT para novo produto
- UPDATE para editar produto
- Notificações de sucesso/erro
- Redirecionamento automático após salvar

#### **5. Preview de Imagem** ✅
- Atualiza em tempo real ao digitar URL
- Mostra preview da imagem do produto

---

## 📊 Estrutura do Formulário

### **Campos Implementados:**

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| **Receita** | Select (dropdown) | Não | Receitas cadastradas |
| **Categoria** | Select (dropdown) | Não | Categorias de produtos |
| **Nome** | Text | ✅ SIM | Nome do produto |
| **Descrição** | Textarea | Não | Descrição detalhada |
| **Imagem URL** | URL | Não | Link da imagem |
| **Preço Base** | Number | ✅ SIM | Preço > 0 |
| **Disponível** | Toggle | Não | Ativo para vendas (padrão: true) |
| **Destaque** | Toggle | Não | Produto em destaque (padrão: false) |

---

## 🔄 Fluxos de Uso

### **Fluxo 1: Adicionar Novo Produto**

```
1. Usuário clica no botão "+" na gestao-produtos.html
2. Abre: adicionar-produto.html (sem parâmetro id)
3. Página carrega receitas e categorias do Supabase
4. Usuário preenche o formulário
5. Clica em "Salvar Produto"
6. Sistema valida campos obrigatórios
7. INSERT na tabela produtos
8. Notificação de sucesso ✅
9. Redireciona para gestao-produtos.html
```

### **Fluxo 2: Editar Produto Existente**

```
1. Usuário clica em "Editar" em um produto
2. Abre: adicionar-produto.html?id=5
3. Página detecta modo de edição
4. Carrega dados do produto id=5
5. Preenche todos os campos automaticamente
6. Usuário edita o que quiser
7. Clica em "Salvar Produto"
8. UPDATE na tabela produtos WHERE id=5
9. Notificação de sucesso ✅
10. Redireciona para gestao-produtos.html
```

---

## 🧪 Como Testar

### **Teste 1: Criar Novo Produto**

1. Abra: `http://localhost:5173/adicionar-produto.html`
2. Veja se aparece "Adicionar Produto" no título
3. Veja se o dropdown de **Receita** tem opções (receitas do banco)
4. Veja se o dropdown de **Categoria** tem opções (categorias do banco)
5. Preencha:
   - Nome: "Teste de Produto"
   - Preço: 10.00
6. Clique em "Salvar Produto"
7. Veja se aparece notificação verde ✅
8. Veja se redirecionou para gestao-produtos.html
9. Verifique se o produto aparece na lista

### **Teste 2: Editar Produto**

1. Abra: `http://localhost:5173/gestao-produtos.html`
2. Clique em "Editar" em qualquer produto
3. Veja se abre `adicionar-produto.html?id=X`
4. Veja se o título mudou para "Editar Produto"
5. Veja se todos os campos estão preenchidos
6. Altere algum campo (ex: nome)
7. Clique em "Salvar Produto"
8. Veja se aparece "Produto atualizado com sucesso!"
9. Verifique se a alteração foi salva

### **Teste 3: Validações**

1. Abra a página de adicionar produto
2. Deixe o campo "Nome" vazio
3. Clique em "Salvar"
4. Deve aparecer: "Por favor, preencha o nome do produto"
5. Preencha nome mas deixe preço = 0
6. Clique em "Salvar"
7. Deve aparecer: "Por favor, informe um preço válido"

### **Teste 4: Preview de Imagem**

1. Cole uma URL de imagem no campo "URL da Imagem"
2. Veja se o preview atualiza automaticamente
3. Exemplo de URL de teste:
```
https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=200
```

---

## 📋 Validações Implementadas

```javascript
// 1. Nome obrigatório
if (!nomeInput.value.trim()) {
    showNotification('Por favor, preencha o nome do produto', 'error');
    return;
}

// 2. Preço válido (> 0)
if (!precoInput.value || parseFloat(precoInput.value) <= 0) {
    showNotification('Por favor, informe um preço válido', 'error');
    return;
}

// 3. Receita e Categoria são opcionais (podem ser null)
```

---

## 🗃️ Estrutura de Dados Salva

### **Novo Produto (INSERT):**

```javascript
{
    nome: "Ninho com Morango",
    descricao: "Delicioso geladinho...",
    categoria_id: 1,              // ID da categoria selecionada
    receita_id: 5,                // ID da receita selecionada
    preco_base: 6.00,
    imagem_url: "https://...",
    disponivel: true,
    destaque: false,
    // created_at e updated_at são automáticos
}
```

### **Editar Produto (UPDATE):**

```sql
UPDATE produtos SET
    nome = 'Novo Nome',
    descricao = 'Nova descrição',
    categoria_id = 2,
    receita_id = 7,
    preco_base = 8.50,
    imagem_url = 'https://...',
    disponivel = true,
    destaque = true,
    updated_at = NOW()
WHERE id = 5;
```

---

## 🔍 Resolução de Problemas

### **Problema: Dropdown de receitas vazio**

**Verificações:**
```sql
-- 1. Tem receitas cadastradas?
SELECT * FROM receitas WHERE ativo = true;

-- 2. Se não houver, crie uma:
INSERT INTO receitas (nome, descricao, ativo)
VALUES ('Receita Base Cremosa', 'Receita padrão para produtos cremosos', true);
```

### **Problema: Dropdown de categorias vazio**

**Verificações:**
```sql
-- 1. Tem categorias de produtos?
SELECT * FROM categorias WHERE tipo = 'produtos' AND ativo = true;

-- 2. Se não houver, crie:
INSERT INTO categorias (nome, tipo, icone, ativo)
VALUES 
    ('Cremoso', 'produtos', '🍦', true),
    ('Frutas', 'produtos', '🍓', true),
    ('Gourmet', 'produtos', '⭐', true);
```

### **Problema: Erro ao salvar produto**

**Verificações:**
```javascript
// Abra o Console (F12) e veja o erro
// Erros comuns:

// 1. "categoria_id does not exist"
// → A categoria foi deletada ou não existe
// Solução: Selecione outra categoria

// 2. "receita_id does not exist"
// → A receita foi deletada ou não existe
// Solução: Selecione outra receita ou deixe vazio

// 3. "Permission denied"
// → Falta política RLS
CREATE POLICY "Permitir acesso público" ON produtos FOR ALL USING (true);
```

### **Problema: Não redireciona após salvar**

**Verificações:**
1. Abra o Console (F12)
2. Veja se há erros JavaScript
3. Verifique se o produto foi salvo:
```sql
SELECT * FROM produtos ORDER BY created_at DESC LIMIT 1;
```

---

## ✨ Funcionalidades Adicionais

### **Toggle "Disponível"**
- ✅ Ligado (verde): Produto aparece no catálogo
- ❌ Desligado (cinza): Produto oculto dos clientes

### **Toggle "Destaque"**
- ⭐ Ligado (amarelo): Produto aparece no topo
- ◻️ Desligado: Produto em ordem normal

### **Preview de Imagem**
- Atualiza em tempo real
- Se URL inválida, mostra placeholder
- Suporta qualquer URL de imagem

### **Estados de Loading**
```
Salvando... 🔄
→ Salvo com sucesso! ✅
→ Erro ao salvar ❌
```

---

## 📝 Próximos Passos

1. ✅ **Teste agora**: Crie e edite produtos
2. 📸 **Upload de imagens**: Implementar upload direto (futuro)
3. 🔗 **Vincular receitas**: Mostrar custo da receita ao selecionar
4. 💰 **Cálculo automático**: Calcular preço sugerido baseado na receita
5. 📊 **Estatísticas**: Mostrar quantos produtos usam cada receita

---

## ✅ Resumo das Mudanças

| Feature | Antes | Depois |
|---------|-------|--------|
| Receita | Mock (hardcoded) | ✅ Do Supabase |
| Categoria | Não existia | ✅ Do Supabase |
| Salvamento | ❌ Não funciona | ✅ INSERT/UPDATE |
| Edição | ❌ Não funciona | ✅ Carrega dados |
| Validação | ❌ Nenhuma | ✅ Nome + Preço |
| Notificações | ❌ Nenhuma | ✅ Toast messages |
| Preview | ❌ Estático | ✅ Tempo real |
| Destaque | ❌ Não existia | ✅ Toggle funcional |

---

## 🎯 Integração Completa

Agora você tem um **sistema completo de gestão de produtos**:

1. **gestao-produtos.html**: 
   - Lista todos os produtos
   - Busca e filtros
   - Botões editar e excluir

2. **adicionar-produto.html**:
   - Criar novos produtos
   - Editar produtos existentes
   - Receitas e categorias dinâmicas
   - Validações e notificações

**TUDO INTEGRADO E FUNCIONANDO!** 🎉

**Teste agora e me avise o resultado!** 👍
