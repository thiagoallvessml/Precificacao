# 🎉 Supabase - Pronto para Usar!

## ✅ O que foi configurado

Você agora tem uma integração completa do Supabase no seu projeto! Aqui está o que foi criado:

### 📦 Arquivos Criados

1. **`supabase-config.js`** - Configuração de credenciais
2. **`supabase-client.js`** - Cliente Supabase inicializado
3. **`supabase-utils.js`** - Funções utilitárias (CRUD, Auth, Storage)
4. **`database-schema.sql`** - Schema completo do banco de dados (15 tabelas)
5. **`supabase-setup.html`** - Página de configuração e teste
6. **`criar-tabelas.html`** - Assistente para criar tabelas
7. **`exemplo-categorias-supabase.html`** - Exemplo prático de CRUD
8. **`DATABASE_DOCS.md`** - Documentação completa do banco
9. **`SUPABASE_GUIA.md`** - Guia de uso do Supabase

---

## 🚀 Próximos Passos

### 1. Criar Tabelas no Banco de Dados

Acesse: **`criar-tabelas.html`** no navegador

Você terá duas opções:
- **Copiar SQL** e colar no Supabase SQL Editor
- **Baixar `database-schema.sql`** e executar

**15 Tabelas serão criadas:**
- ✅ categorias
- ✅ marketplaces
- ✅ insumos
- ✅ produtos
- ✅ receitas
- ✅ receita_insumos
- ✅ precos_marketplace
- ✅ pedidos
- ✅ pedido_itens
- ✅ producao
- ✅ movimentacoes_estoque
- ✅ despesas
- ✅ equipamentos
- ✅ chaves_pix
- ✅ configuracoes

---

## 💡 Como Usar

### Exemplo Básico

```javascript
import { getAllRecords, insertRecord, updateRecord, deleteRecord } from './supabase-utils.js';

// Buscar todos os produtos
const { data, error } = await getAllRecords('produtos');

// Inserir novo produto
await insertRecord('produtos', {
    nome: 'Geladinho de Morango',
    preco_base: 2.50,
    disponivel: true
});

// Atualizar produto
await updateRecord('produtos', 123, {
    preco_base: 3.00
});

// Deletar produto
await deleteRecord('produtos', 123);
```

### Buscar com Filtros

```javascript
import { getRecordsWhere } from './supabase-utils.js';

const { data } = await getRecordsWhere('produtos', {
    disponivel: true,
    categoria_id: 5
});
```

### Autenticação

```javascript
import { signIn, signUp, getCurrentUser, signOut } from './supabase-utils.js';

// Login
await signIn('email@exemplo.com', 'senha123');

// Cadastro
await signUp('email@exemplo.com', 'senha123');

// Usuário atual
const user = await getCurrentUser();

// Logout
await signOut();
```

---

## 📚 Documentação

| Arquivo | Descrição |
|---------|-----------|
| `SUPABASE_GUIA.md` | Guia completo de uso do Supabase |
| `DATABASE_DOCS.md` | Documentação das tabelas do banco |
| `database-schema.sql` | Script SQL com todas as tabelas |

---

## 🔗 Links Rápidos

### Páginas do Projeto
- 🏠 [Menu Principal](index.html)
- ☁️ [Configurar Supabase](supabase-setup.html)
- 🗄️ [Criar Tabelas](criar-tabelas.html)
- 💻 [Exemplo CRUD](exemplo-categorias-supabase.html)

### Recursos Externos
- 📖 [Documentação Supabase](https://supabase.com/docs)
- 🎓 [Tutoriais Supabase](https://supabase.com/docs/guides/getting-started/tutorials)
- 🎥 [Vídeos no YouTube](https://www.youtube.com/@Supabase)

---

## 🗄️ Estrutura do Banco de Dados

### Tabelas Principais

**Produtos e Receitas**
```
produtos → receitas → receita_insumos → insumos
```

**Vendas**
```
pedidos → pedido_itens → produtos
pedidos → marketplaces
```

**Precificação**
```
produtos → precos_marketplace → marketplaces
```

**Produção e Estoque**
```
producao → receitas → produtos
movimentacoes_estoque → insumos
```

**Gestão Financeira**
```
despesas → categorias
equipamentos
chaves_pix
```

---

## 🔐 Segurança

✅ **Row Level Security (RLS)** habilitado em todas as tabelas  
✅ Políticas de segurança configuradas  
✅ Apenas usuários autenticados podem acessar dados  
✅ Arquivo `supabase-config.js` no `.gitignore`

---

## 🎯 Checklist de Implementação

- [ ] Configurar credenciais em `supabase-config.js`
- [ ] Testar conexão em `supabase-setup.html`
- [ ] Criar tabelas usando `criar-tabelas.html`
- [ ] Verificar tabelas no Supabase Table Editor
- [ ] Testar CRUD com `exemplo-categorias-supabase.html`
- [ ] Adaptar as páginas HTML para usar o Supabase
- [ ] Implementar autentication (opcional)
- [ ] Configurar storage para imagens (opcional)

---

## 📊 Funcionalidades Disponíveis

### CRUD (Create, Read, Update, Delete)
- ✅ `getAllRecords()` - Buscar todos
- ✅ `getRecordById()` - Buscar por ID
- ✅ `getRecordsWhere()` - Buscar com filtros
- ✅ `insertRecord()` - Inserir
- ✅ `updateRecord()` - Atualizar
- ✅ `deleteRecord()` - Deletar

### Autenticação
- ✅ `signIn()` - Login
- ✅ `signUp()` - Cadastro
- ✅ `signOut()` - Logout
- ✅ `getCurrentUser()` - Usuário atual

### Storage (Arquivos)
- ✅ `uploadFile()` - Upload
- ✅ `getPublicUrl()` - URL pública
- ✅ `deleteFile()` - Deletar arquivo

---

## 🆘 Problemas Comuns

### "Supabase não configurado"
Configure suas credenciais em `supabase-config.js`

### Erro de CORS
Adicione `http://localhost:5173` nas URLs permitidas no Supabase

### Dados não aparecem
1. Verifique se a tabela existe
2. Confira as políticas de RLS
3. Veja o console do navegador para erros

### Erro de permissão
Certifique-se de que o usuário está autenticado ou ajuste as políticas de RLS

---

## 💪 Suporte

- 📧 [Documentação do Supabase](https://supabase.com/docs)
- 💬 [Discord do Supabase](https://discord.supabase.com/)
- 🐛 [GitHub Issues](https://github.com/supabase/supabase/issues)

---

**Pronto para começar! 🚀**

Abra `supabase-setup.html` e siga o guia passo a passo!
