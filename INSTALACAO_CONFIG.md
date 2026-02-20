# 🚀 Guia Rápido de Instalação - Configurações no Supabase

## ✅ Passos para Ativar

### 1️⃣ Verificar se a tabela `configuracoes` existe

Acesse o **SQL Editor** do Supabase e execute:

```sql
-- Verificar se a tabela existe
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE table_schema = 'public'
   AND table_name = 'configuracoes'
);
```

**Se retornar `true`**: A tabela já existe! ✅ Vá para o passo 2.
**Se retornar `false`**: Execute o `database-schema.sql` completo primeiro.

---

### 2️⃣ Inserir configurações iniciais

No **SQL Editor** do Supabase, execute:

```sql
-- Insere ou atualiza as configurações padrão
INSERT INTO configuracoes (chave, valor, tipo, descricao, categoria)
VALUES 
    ('peso_botijao_gas', '13', 'number', 'Peso do botijão de gás em kg', 'producao'),
    ('preco_botijao_gas', '110.00', 'number', 'Preço do botijão de gás em R$', 'financeiro'),
    ('custo_kwh', '0.85', 'number', 'Custo por kWh de energia em R$', 'financeiro'),
    ('custo_mao_obra_hora', '25.00', 'number', 'Custo de mão de obra por hora em R$', 'financeiro')
ON CONFLICT (chave) DO UPDATE SET
    valor = EXCLUDED.valor,
    descricao = EXCLUDED.descricao,
    categoria = EXCLUDED.categoria,
    updated_at = NOW();
```

---

### 3️⃣ Permitir acesso público (Desenvolvimento)

⚠️ **IMPORTANTE**: Isso é apenas para desenvolvimento! 

No **SQL Editor** do Supabase, execute:

```sql
-- Permite acesso público à tabela configuracoes
DROP POLICY IF EXISTS "Permitir tudo para usuários autenticados" ON configuracoes;
CREATE POLICY "Permitir acesso público" ON configuracoes FOR ALL USING (true);
```

Para **produção**, implemente autenticação adequada!

---

### 4️⃣ Verificar se funcionou

Execute no SQL Editor:

```sql
-- Lista todas as configurações
SELECT * FROM configuracoes ORDER BY categoria, chave;
```

Você deve ver 4 registros (ou mais):
- `peso_botijao_gas`
- `preco_botijao_gas`
- `custo_kwh`
- `custo_mao_obra_hora`

---

## 🎯 Testar na Interface

1. Abra a página: `http://localhost:5173/configuracoes.html` (ou a porta do seu servidor)
2. Os campos devem ser preenchidos automaticamente com os valores do banco
3. Altere os valores
4. Clique em "Salvar Todas as Configurações"
5. Recarregue a página - os valores devem persistir! ✅

---

## 📊 Comandos SQL Úteis

### Ver todas as configurações:
```sql
SELECT chave, valor, tipo, categoria, updated_at 
FROM configuracoes 
ORDER BY categoria, chave;
```

### Resetar para valores padrão:
```sql
UPDATE configuracoes SET valor = '13' WHERE chave = 'peso_botijao_gas';
UPDATE configuracoes SET valor = '110.00' WHERE chave = 'preco_botijao_gas';
UPDATE configuracoes SET valor = '0.85' WHERE chave = 'custo_kwh';
UPDATE configuracoes SET valor = '25.00' WHERE chave = 'custo_mao_obra_hora';
```

### Adicionar uma nova configuração:
```sql
INSERT INTO configuracoes (chave, valor, tipo, descricao, categoria)
VALUES ('nome_empresa', 'Minha Empresa', 'string', 'Nome da empresa', 'geral');
```

### Deletar uma configuração:
```sql
DELETE FROM configuracoes WHERE chave = 'nome_configuracao';
```

---

## 🔍 Troubleshooting

### Problema: "Error: relation configuracoes does not exist"
**Solução**: Execute o `database-schema.sql` completo no SQL Editor.

### Problema: "Error: permission denied"
**Solução**: Execute o script de permissões públicas (passo 3).

### Problema: Valores não salvam
**Solução**: 
1. Abra o Console do navegador (F12)
2. Veja se há erros
3. Verifique se o `supabase-config.js` está configurado corretamente

### Problema: Página não carrega configurações
**Solução**:
1. Verifique se os valores existem no banco (use a query do passo 4)
2. Limpe o cache do navegador
3. Verifique o Console do navegador

---

## ✅ Checklist de Instalação

- [ ] Tabela `configuracoes` existe
- [ ] Políticas de acesso configuradas
- [ ] Configurações iniciais inseridas
- [ ] Página `configuracoes.html` carrega valores
- [ ] Consegue salvar novos valores
- [ ] Valores persistem após recarregar página

---

## 🎉 Próximos Passos

Depois de tudo funcionando:

1. **Teste a página de exemplo**: Abra `exemplo-uso-config.html`
2. **Use em suas páginas**: Importe o `config-helper.js`
3. **Adicione mais configurações**: Nome da empresa, impostos, etc.
4. **Configure autenticação**: Para produção, implemente RLS adequado

---

**Dúvidas?** Consulte o arquivo `CONFIGURACOES_SUPABASE.md` para documentação completa!
