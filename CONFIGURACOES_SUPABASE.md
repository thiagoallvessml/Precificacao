# 📋 Integração da Página de Configurações com Supabase

## ✅ O que foi feito

A página `configuracoes.html` agora está **completamente integrada** com o Supabase! Isso permite que você:

1. **Salve** todas as configurações de custos no banco de dados
2. **Carregue** automaticamente as configurações salvas ao abrir a página
3. **Persista** os dados entre sessões e dispositivos

---

## 🔧 Configurações Disponíveis

A página gerencia 4 configurações principais:

| Configuração | Chave no Banco | Descrição |
|--------------|----------------|-----------|
| **Peso do Botijão de Gás** | `peso_botijao_gas` | Peso do botijão em kg (ex: 13kg) |
| **Preço do Botijão** | `preco_botijao_gas` | Preço do botijão em R$ |
| **Custo por kWh** | `custo_kwh` | Custo da energia elétrica por kWh |
| **Custo Mão de Obra/Hora** | `custo_mao_obra_hora` | Valor da hora trabalhada |

---

## 🚀 Como Usar

### 1. **Configurar o Banco de Dados**

Primeiro, certifique-se de que a tabela `configuracoes` existe no Supabase. Se você ainda não executou, rode o script:

```sql
-- No SQL Editor do Supabase, execute:
-- arquivo: database-schema.sql
```

### 2. **Inserir Configurações Iniciais (Opcional)**

Para popular com valores padrão, execute:

```sql
-- No SQL Editor do Supabase, execute:
-- arquivo: configuracoes-iniciais.sql
```

### 3. **Garantir Acesso Público (Desenvolvimento)**

Se estiver em desenvolvimento, certifique-se de executar:

```sql
-- No SQL Editor do Supabase, execute:
-- arquivo: supabase-allow-public.sql
```

⚠️ **IMPORTANTE**: Para produção, implemente autenticação adequada!

---

## 💻 Como Funciona o Código

### **Carregar Configurações**

Ao abrir a página `configuracoes.html`, o código:

1. Busca cada configuração na tabela `configuracoes` usando a chave única
2. Preenche os campos de input com os valores salvos
3. Exibe um indicador de loading durante o carregamento

```javascript
async function carregarConfiguracoes() {
    const pesoGas = await getConfigValue('peso_botijao_gas');
    if (pesoGas) {
        pesoGasInput.value = pesoGas.valor;
    }
    // ... outros campos
}
```

### **Salvar Configurações**

Ao clicar no botão "Salvar Todas as Configurações":

1. Valida que todos os valores são maiores que zero
2. Para cada configuração:
   - Verifica se já existe no banco
   - Se existe: **atualiza** o valor
   - Se não existe: **insere** um novo registro
3. Exibe uma notificação de sucesso ou erro

```javascript
async function saveConfigValue(chave, valor, descricao, categoria) {
    const existing = await getConfigValue(chave);
    
    if (existing) {
        // Atualiza
        await supabase.from('configuracoes')
            .update({ valor: String(valor) })
            .eq('chave', chave);
    } else {
        // Insere
        await supabase.from('configuracoes')
            .insert([{ chave, valor, tipo: 'number', descricao, categoria }]);
    }
}
```

---

## 🎨 Recursos Implementados

### ✨ **Notificações Toast**

O sistema exibe notificações flutuantes elegantes:
- ✅ **Verde**: Sucesso ao salvar
- ❌ **Vermelho**: Erro ao salvar ou carregar
- ℹ️ **Azul**: Informações gerais

### 🔄 **Estados de Loading**

O botão de salvar mostra o estado atual:
- **Carregando...**: Ao carregar dados do banco
- **Salvando...**: Ao salvar no banco
- **Salvar Todas as Configurações**: Estado normal

### ✅ **Validação de Dados**

Antes de salvar, o sistema valida:
- Todos os campos devem ser preenchidos
- Todos os valores devem ser maiores que zero
- Conversão automática para números

---

## 📊 Estrutura da Tabela `configuracoes`

```sql
CREATE TABLE configuracoes (
    id BIGSERIAL PRIMARY KEY,
    chave TEXT NOT NULL UNIQUE,           -- Identificador único (ex: 'peso_botijao_gas')
    valor TEXT,                            -- Valor armazenado como texto
    tipo TEXT DEFAULT 'string',            -- Tipo: 'number', 'string', 'boolean', 'json'
    descricao TEXT,                        -- Descrição legível
    categoria TEXT,                        -- Categoria: 'producao', 'financeiro', etc
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🔐 Segurança

### **Desenvolvimento**
Atualmente, a tabela está com acesso público para facilitar o desenvolvimento.

### **Produção** 
Para produção, você deve:

1. Remover as políticas de acesso público
2. Implementar autenticação de usuários
3. Criar políticas RLS (Row Level Security) que:
   - Permitam leitura para usuários autenticados
   - Permitam escrita apenas para administradores

Exemplo de política RLS para produção:

```sql
-- Remove políticas públicas
DROP POLICY IF EXISTS "Permitir acesso público" ON configuracoes;

-- Cria políticas seguras
CREATE POLICY "Leitura para autenticados" 
    ON configuracoes FOR SELECT 
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Escrita apenas para admins" 
    ON configuracoes FOR ALL 
    USING (auth.jwt() ->> 'role' = 'admin');
```

---

## 🐛 Solução de Problemas

### **Problema: Configurações não carregam**

**Soluções:**
1. Verifique se o Supabase está configurado em `supabase-config.js`
2. Verifique no Console do navegador se há erros
3. Certifique-se de que executou o `supabase-allow-public.sql`
4. Verifique se a tabela `configuracoes` existe

### **Problema: Erro ao salvar**

**Soluções:**
1. Verifique se todos os campos têm valores válidos (> 0)
2. Verifique as permissões da tabela no Supabase
3. Consulte o Console do navegador para mensagens de erro detalhadas

### **Problema: Notificações não aparecem**

**Soluções:**
1. Verifique se há adblock ou extensões bloqueando
2. Limpe o cache do navegador
3. Teste em modo anônimo/privado

---

## 📝 Próximos Passos Sugeridos

1. **Usar as configurações em outras páginas**
   - Importe as configurações em páginas de cálculo de custos
   - Use `getConfigValue('chave')` para buscar valores

2. **Adicionar mais configurações**
   - Margem de lucro padrão
   - Impostos e taxas
   - Configurações de notificação

3. **Criar página de administração**
   - Gerenciar todas as configurações do sistema
   - Exportar/importar configurações
   - Histórico de alterações

---

## 🎯 Exemplo de Uso em Outras Páginas

```javascript
// Em qualquer outra página
import { getSupabase } from './supabase-client.js';

async function buscarCustoMaoObra() {
    const supabase = getSupabase();
    const { data } = await supabase
        .from('configuracoes')
        .select('valor')
        .eq('chave', 'custo_mao_obra_hora')
        .single();
    
    return parseFloat(data?.valor || 0);
}

// Usar em cálculos
const custoHora = await buscarCustoMaoObra();
const custoTotal = custoHora * horasTrabalhadas;
```

---

## ✅ Checklist de Implementação

- [x] Criar integração com Supabase
- [x] Implementar função de carregar configurações
- [x] Implementar função de salvar configurações
- [x] Adicionar validação de dados
- [x] Criar notificações toast
- [x] Adicionar estados de loading
- [x] Criar script SQL de configurações iniciais
- [x] Documentar o código
- [ ] Testar em produção com autenticação
- [ ] Implementar histórico de alterações (futuro)

---

**Pronto!** 🎉 Agora suas configurações estão integradas com o Supabase e serão persistidas no banco de dados!
