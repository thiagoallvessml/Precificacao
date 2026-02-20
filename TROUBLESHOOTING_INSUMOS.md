# 🐛 TROUBLESHOOTING: Insumos Não Aparecem em Adicionar Receita

## 🎯 Problema

Os dropdowns de **Ingredientes**, **Embalagens** e **Equipamentos** aparecem vazios na página `adicionar-receita.html`.

---

## 🔍 Possíveis Causas

1. ❌ Não há insumos cadastrados no banco
2. ❌ Os insumos estão com `ativo = false`
3. ❌ Os insumos não têm o campo `tipo` preenchido corretamente
4. ❌ Falta permissão RLS na tabela `insumos`
5. ❌ Erro de JavaScript (verificar Console)

---

## ✅ Passo a Passo para Diagnosticar

### **PASSO 1: Verificar se há insumos cadastrados**

Execute no **SQL Editor do Supabase**:

```sql
-- Ver quantos insumos existem por tipo
SELECT 
    tipo,
    COUNT(*) as total,
    COUNT(CASE WHEN ativo = true THEN 1 END) as ativos
FROM insumos
GROUP BY tipo;
```

**Resultado Esperado:**
```
tipo         | total | ativos
-------------|-------|--------
ingrediente  | 10    | 8
embalagem    | 5     | 5
equipamento  | 3     | 3
```

**Se não retornar nada:** Não há insumos! Vá para o PASSO 5 (inserir dados).

---

### **PASSO 2: Verificar detalhes dos insumos**

```sql
-- Ver ingredientes cadastrados
SELECT id, nome, tipo, unidade_medida, custo_unitario, ativo
FROM insumos
WHERE tipo = 'ingrediente'
ORDER BY nome;
```

**Verifique:**
- ✅ Coluna `tipo` = **'ingrediente'** (exatamente assim, minúsculo)
- ✅ Coluna `ativo` = **true**
- ✅ Coluna `custo_unitario` > **0**

Repita para:
```sql
WHERE tipo = 'embalagem'
WHERE tipo = 'equipamento'
```

---

### **PASSO 3: Verificar problemas comuns**

#### **3.1 Insumos sem tipo:**
```sql
SELECT id, nome, tipo
FROM insumos
WHERE tipo IS NULL;
```

**Se encontrar:** Execute:
```sql
UPDATE insumos 
SET tipo = 'ingrediente' 
WHERE id = X AND tipo IS NULL;
```

#### **3.2 Insumos com tipo errado:**
```sql
SELECT id, nome, tipo
FROM insumos
WHERE tipo NOT IN ('ingrediente', 'embalagem', 'equipamento');
```

**Tipos válidos:**
- ✅ `'ingrediente'` (singular, minúsculo)
- ✅ `'embalagem'` (singular, minúsculo)
- ✅ `'equipamento'` (singular, minúsculo)

**Tipos INVÁLIDOS:**
- ❌ `'ingredientes'` (plural)
- ❌ `'Ingrediente'` (maiúsculo)
- ❌ `'materia_prima'`

#### **3.3 Insumos inativos:**
```sql
SELECT COUNT(*) 
FROM insumos 
WHERE ativo = false;
```

**Para ativar:**
```sql
UPDATE insumos 
SET ativo = true 
WHERE id = X;
```

---

### **PASSO 4: Verificar permissões RLS**

```sql
SELECT tablename, policyname
FROM pg_policies
WHERE tablename = 'insumos';
```

**Se não retornar nada**, criar política:

```sql
CREATE POLICY "Permitir acesso público" 
ON insumos 
FOR ALL 
USING (true);
```

---

### **PASSO 5: Inserir dados de exemplo (se necessário)**

Se não houver insumos, execute o arquivo completo:

📁 **`diagnostico-insumos.sql`** (seção 5)

Ou copie e execute:

```sql
-- INGREDIENTES
INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, ativo)
VALUES 
    ('Leite Condensado Moça 395g', 'ingrediente', 'g', 13.70, true),
    ('Creme de Leite Nestlé 200g', 'ingrediente', 'g', 4.50, true),
    ('Leite Ninho 400g', 'ingrediente', 'g', 18.90, true),
    ('Nutella 350g', 'ingrediente', 'g', 22.50, true),
    ('Morango Congelado 1kg', 'ingrediente', 'kg', 15.00, true);

-- EMBALAGENS
INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, ativo)
VALUES 
    ('Saco 6x24 (100un)', 'embalagem', 'un', 0.15, true),
    ('Saco 5x23 (100un)', 'embalagem', 'un', 0.12, true),
    ('Pote 100ml com Tampa', 'embalagem', 'un', 0.80, true);

-- EQUIPAMENTOS
INSERT INTO insumos (nome, tipo, unidade_medida, custo_unitario, ativo)
VALUES 
    ('Freezer Horizontal 400L', 'equipamento', 'kWh', 0.85, true),
    ('Liquidificador Industrial 2L', 'equipamento', 'kWh', 0.50, true),
    ('Batedeira Planetária 5L', 'equipamento', 'kWh', 0.40, true);
```

---

### **PASSO 6: Verificar erros JavaScript**

1. Abra a página: `http://localhost:5173/adicionar-receita.html`
2. Pressione **F12** para abrir DevTools
3. Vá na aba **Console**
4. Procure por mensagens de erro em vermelho

**Procure por:**
```
✅ Dados carregados: { ingredientes: X, embalagens: Y, equipamentos: Z }
```

Se aparecer:
```
Erro ao carregar insumos do tipo ingrediente: ...
```

Isso indica problema de **permissão** ou **conexão** com Supabase.

---

## 🧪 Teste Final

Depois de corrigir, execute:

```sql
-- Diagnóstico completo
SELECT 
    tipo,
    COUNT(*) as total_cadastrados,
    STRING_AGG(nome, ', ') as exemplos
FROM insumos
WHERE ativo = true
GROUP BY tipo
ORDER BY tipo;
```

**Resultado esperado:**
```
tipo         | total | exemplos
-------------|-------|----------------------------------
ingrediente  | 5     | Leite Condensado, Creme de Leite, ...
embalagem    | 3     | Saco 6x24, Pote 100ml, ...
equipamento  | 3     | Freezer, Liquidificador, ...
```

---

## ✅ Checklist de Verificação

Marque cada item conforme verifica:

- [ ] **Existem insumos cadastrados?**
  ```sql
  SELECT COUNT(*) FROM insumos;
  ```

- [ ] **Os tipos estão corretos?**
  ```sql
  SELECT DISTINCT tipo FROM insumos;
  -- Deve retornar: ingrediente, embalagem, equipamento
  ```

- [ ] **Os insumos estão ativos?**
  ```sql
  SELECT COUNT(*) FROM insumos WHERE ativo = true;
  ```

- [ ] **Há custo unitário definido?**
  ```sql
  SELECT COUNT(*) FROM insumos WHERE custo_unitario > 0;
  ```

- [ ] **Há política RLS?**
  ```sql
  SELECT COUNT(*) FROM pg_policies WHERE tablename = 'insumos';
  ```

- [ ] **A página carrega sem erros?**
  - Abra Console (F12) e veja se há erros

---

## 🎯 Solução Rápida

Se você só quer que funcione **agora**, execute:

```sql
-- 1. Criar política (se não existir)
CREATE POLICY IF NOT EXISTS "Permitir acesso público" 
ON insumos FOR ALL USING (true);

-- 2. Inserir dados de exemplo
-- (copie da seção PASSO 5 acima)

-- 3. Verificar
SELECT tipo, COUNT(*) FROM insumos WHERE ativo = true GROUP BY tipo;
```

Depois, **recarregue a página** com **CTRL+SHIFT+R** (hard reload).

---

## 📁 Arquivos de Referência

- 📝 **`diagnostico-insumos.sql`**: Script completo de diagnóstico
- 📝 **`database-schema.sql`**: Schema da tabela insumos (linha 57)
- 🌐 **`adicionar-receita.html`**: Página que carrega os insumos

---

## 💡 Dica

Depois de cadastrar insumos, você pode gerenciá-los pela interface:

```
http://localhost:5173/gestao-insumos.html
```

Lá você pode:
- ✅ Adicionar novos insumos
- ✅ Editar insumos existentes
- ✅ Ativar/desativar insumos
- ✅ Ver estoque

---

## ❓ Ainda Não Funciona?

Se depois de seguir todos os passos ainda não funcionar:

1. **Tire um print** do Console (F12)
2. **Execute** e **tire print** dos resultados:
   ```sql
   SELECT * FROM insumos WHERE ativo = true LIMIT 5;
   ```
3. **Me mostre** os prints para eu ver o que está acontecendo

---

**BOA SORTE!** 🚀

Lembre-se: O problema mais comum é **não ter insumos cadastrados**! 😊
