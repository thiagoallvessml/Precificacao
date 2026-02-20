# Guia de Integração com Supabase

## 📚 O que é Supabase?

Supabase é uma plataforma de backend como serviço (BaaS) open-source que fornece:
- **Banco de dados PostgreSQL** hospedado na nuvem
- **Autenticação** de usuários
- **APIs RESTful e Realtime** automáticas
- **Storage** para arquivos
- **Row Level Security (RLS)** para segurança

---

## 🚀 Configuração Rápida

### 1. Instalar Dependências
```bash
npm install @supabase/supabase-js
```
✅ Já foi executado!

### 2. Obter Credenciais do Supabase

1. Acesse [https://app.supabase.com/](https://app.supabase.com/)
2. Crie uma conta (se ainda não tiver)
3. Crie um novo projeto
4. Vá em **Settings** → **API**
5. Copie:
   - **Project URL** (ex: `https://seu-projeto.supabase.co`)
   - **anon public key** (chave pública)

### 3. Configurar Credenciais

Abra o arquivo `supabase-config.js` e substitua:

```javascript
const SUPABASE_URL = 'https://seu-projeto.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

⚠️ **IMPORTANTE**: Nunca compartilhe a chave `service_role`! Use apenas a `anon public` key.

---

## 📁 Estrutura dos Arquivos

```
Precificacao/
├── supabase-config.js     # Configuração (credenciais)
├── supabase-client.js     # Cliente Supabase inicializado
├── supabase-utils.js      # Funções utilitárias
└── supabase-setup.html    # Página de teste e configuração
```

---

## 💻 Como Usar

### Importar o Cliente

```javascript
import { getSupabase } from './supabase-client.js';

const supabase = getSupabase();
```

### Exemplos de Uso

#### 1. **Buscar Todos os Registros**

```javascript
import { getAllRecords } from './supabase-utils.js';

const { data, error } = await getAllRecords('produtos');
if (error) {
    console.error('Erro:', error);
} else {
    console.log('Produtos:', data);
}
```

#### 2. **Buscar por ID**

```javascript
import { getRecordById } from './supabase-utils.js';

const { data, error } = await getRecordById('produtos', 123);
```

#### 3. **Inserir Novo Registro**

```javascript
import { insertRecord } from './supabase-utils.js';

const novoProduto = {
    nome: 'Geladinho de Morango',
    preco: 2.50,
    estoque: 100
};

const { data, error } = await insertRecord('produtos', novoProduto);
```

#### 4. **Atualizar Registro**

```javascript
import { updateRecord } from './supabase-utils.js';

const { data, error } = await updateRecord('produtos', 123, {
    preco: 3.00,
    estoque: 150
});
```

#### 5. **Deletar Registro**

```javascript
import { deleteRecord } from './supabase-utils.js';

const { error } = await deleteRecord('produtos', 123);
```

#### 6. **Buscar com Filtros**

```javascript
import { getRecordsWhere } from './supabase-utils.js';

const { data, error } = await getRecordsWhere('produtos', {
    categoria: 'frutas',
    ativo: true
});
```

---

## 🔐 Autenticação

### Login

```javascript
import { signIn } from './supabase-utils.js';

const { data, error } = await signIn('email@exemplo.com', 'senha123');
if (!error) {
    console.log('Usuário logado:', data.user);
}
```

### Cadastro

```javascript
import { signUp } from './supabase-utils.js';

const { data, error } = await signUp('email@exemplo.com', 'senha123');
```

### Logout

```javascript
import { signOut } from './supabase-utils.js';

await signOut();
```

### Obter Usuário Atual

```javascript
import { getCurrentUser } from './supabase-utils.js';

const user = await getCurrentUser();
console.log('Usuário atual:', user);
```

---

## 📦 Storage (Arquivos)

### Upload de Arquivo

```javascript
import { uploadFile } from './supabase-utils.js';

const fileInput = document.querySelector('input[type="file"]');
const file = fileInput.files[0];

const { data, error } = await uploadFile('imagens', 'produtos/foto.jpg', file);
```

### Obter URL Pública

```javascript
import { getPublicUrl } from './supabase-utils.js';

const url = getPublicUrl('imagens', 'produtos/foto.jpg');
console.log('URL:', url);
```

### Deletar Arquivo

```javascript
import { deleteFile } from './supabase-utils.js';

await deleteFile('imagens', 'produtos/foto.jpg');
```

---

## 🗄️ Criando Tabelas no Supabase

### Exemplo: Tabela de Produtos

1. No Supabase, vá em **Table Editor**
2. Clique em **New Table**
3. Configure:

```sql
CREATE TABLE produtos (
    id BIGSERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    estoque INTEGER DEFAULT 0,
    categoria TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Habilitar Row Level Security (RLS)

Para proteger seus dados:

```sql
-- Habilitar RLS
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

-- Permitir leitura para todos
CREATE POLICY "Permitir leitura pública"
ON produtos FOR SELECT
USING (true);

-- Permitir escrita apenas para usuários autenticados
CREATE POLICY "Permitir escrita autenticada"
ON produtos FOR ALL
USING (auth.uid() IS NOT NULL);
```

---

## 🌐 Testar a Configuração

1. Abra a página `supabase-setup.html` no navegador
2. Siga o guia passo a passo
3. Clique em "Testar Conexão"
4. Se aparecer ✅, está tudo certo!

---

## 📖 Recursos Adicionais

- [Documentação Oficial do Supabase](https://supabase.com/docs)
- [Guia de Autenticação](https://supabase.com/docs/guides/auth)
- [Guia de Database](https://supabase.com/docs/guides/database)
- [Guia de Storage](https://supabase.com/docs/guides/storage)
- [Exemplos de Código](https://github.com/supabase/examples)

---

## 🆘 Troubleshooting

### "Supabase não configurado"
- Verifique se você configurou as credenciais no `supabase-config.js`
- Certifique-se de que a URL e a chave estão corretas

### Erro de CORS
- Verifique as configurações de domínio permitido no Supabase
- Em desenvolvimento, adicione `http://localhost:5173` nas URLs permitidas

### Erro de permissão
- Verifique as políticas de Row Level Security (RLS)
- Certifique-se de que o usuário está autenticado se a política exigir

### Dados não aparecem
- Confirme que a tabela existe no Supabase
- Verifique se há dados na tabela
- Confira o console do navegador para erros

---

## 🎯 Próximos Passos

1. ✅ Configurar credenciais no `supabase-config.js`
2. ✅ Testar conexão na página `supabase-setup.html`
3. 📝 Criar suas tabelas no Supabase
4. 🔐 Configurar autenticação (se necessário)
5. 💾 Integrar com suas páginas HTML existentes

---

**Dúvidas?** Consulte a [documentação oficial](https://supabase.com/docs) ou abra uma issue!
