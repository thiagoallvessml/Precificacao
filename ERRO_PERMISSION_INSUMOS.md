# 🔒 ERRO: Permission Denied - Insumos

## 🐛 Erro Detectado

```
Erro ao carregar insumos do tipo ingrediente: Object
Erro ao carregar insumos do tipo embalagem: Object
Erro ao carregar insumos do tipo equipamento: Object
```

## 🎯 Causa

A tabela **`insumos`** está com **RLS (Row Level Security)** habilitado, mas **sem políticas de acesso**!

Isso impede que o JavaScript acesse os dados, mesmo que existam insumos cadastrados.

---

## ✅ Solução (RÁPIDA)

### **Execute este SQL no Supabase SQL Editor:**

```sql
-- Habilitar RLS
ALTER TABLE insumos ENABLE ROW LEVEL SECURITY;

-- Criar política pública
CREATE POLICY "Permitir acesso público" 
ON insumos 
FOR ALL 
TO public
USING (true)
WITH CHECK (true);

-- Verificar se funcionou
SELECT COUNT(*) FROM insumos;
```

**Se retornar um número ≥ 0:** Funcionou! ✅

---

## 📋 Script Completo

Para corrigir **todas as tabelas** de uma vez, execute o arquivo:

📁 **`supabase-allow-public.sql`**

Este script cria políticas para:
- ✅ `insumos`
- ✅ `categorias`
- ✅ `produtos`
- ✅ `receitas`
- ✅ `receitas_insumos`

---

## 🧪 Testar Depois de Executar

1. **Execute o SQL** acima
2. **Recarregue a página** com **CTRL+SHIFT+R**
3. **Abra o Console** (F12)
4. Deve aparecer:
   ```
   ✅ Dados carregados: {
       ingredientes: X,
       embalagens: Y,
       equipamentos: Z
   }
   ```

---

## 🔍 Verificar Agora

Execute este SQL para ver o erro completo:

```sql
-- Ver políticas da tabela insumos
SELECT 
    policyname,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'insumos';
```

**Se não retornar nada:** Não há políticas! Execute a solução acima.

---

## ⚠️ IMPORTANTE

O erro "Object" acontecia porque o erro não estava sendo convertido em texto.

**Agora melhorei o código** para mostrar a mensagem real do erro!

Depois de executar o SQL, **recarregue a página** e veja a mensagem detalhada no Console se ainda houver erro.

---

## 📝 Resumo

| Passo | Ação |
|-------|------|
| 1️⃣ | Abra **Supabase SQL Editor** |
| 2️⃣ | Execute **`supabase-allow-public.sql`** |
| 3️⃣ | Ou execute o SQL rápido acima |
| 4️⃣ | Recarregue a página com **CTRL+SHIFT+R** |
| 5️⃣ | Veja o Console (F12) para confirmar |

---

**EXECUTE O SQL AGORA E ME AVISE SE FUNCIONOU!** 🚀
