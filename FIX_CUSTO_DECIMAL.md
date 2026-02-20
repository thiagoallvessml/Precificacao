# Problema: Custo Unitário com 3 Casas Decimais

## 🐛 Problema Identificado

Ao tentar salvar um custo unitário com 3 casas decimais (ex: `0.028`), o sistema arredonda para 2 casas decimais (ex: `0.03`).

## 🔍 Causa Raiz

A coluna `custo_unitario` na tabela `insumos` está definida como `DECIMAL(10,2)` no banco de dados, que significa:
- **10**: Número total de dígitos
- **2**: Número de casas decimais

Portanto, o PostgreSQL automaticamente arredonda qualquer valor para 2 casas decimais:
- `0.028` → `0.03` ❌
- `0.025` → `0.03` ❌  
- `0.024` → `0.02` ❌

## ✅ Solução

Alterar a definição da coluna para `DECIMAL(10,3)` para aceitar 3 casas decimais.

### Passos para Corrigir:

1. **Execute o script SQL no Supabase:**
   - Abra o arquivo: `fix-custo-unitario-decimal.sql`
   - Copie o conteúdo
   - Cole no SQL Editor do Supabase
   - Execute o script

2. **O que o script faz:**
   ```sql
   -- Altera a tabela insumos
   ALTER TABLE insumos 
   ALTER COLUMN custo_unitario TYPE DECIMAL(10,3);

   -- Altera a tabela movimentacoes_estoque
   ALTER TABLE movimentacoes_estoque 
   ALTER COLUMN custo_unitario TYPE DECIMAL(10,3);
   ```

3. **Resultado esperado:**
   - Após executar, o banco aceitará valores como:
     - `0.028` ✅
     - `0.125` ✅
     - `5.123` ✅

## 📋 Verificação

Após executar o script, você pode verificar com:

```sql
SELECT 
    table_name,
    column_name,
    data_type,
    numeric_precision,
    numeric_scale
FROM information_schema.columns
WHERE table_name IN ('insumos', 'movimentacoes_estoque')
    AND column_name = 'custo_unitario';
```

**Resultado correto:**
- `numeric_precision`: 10
- `numeric_scale`: **3** (era 2 antes)

## 🎯 Após a Correção

1. Todos os custos antigos permanecerão (ex: `5.50` vira `5.500`)
2. Novos custos poderão ter 3 casas decimais
3. O cálculo ficará mais preciso para insumos de baixo valor
