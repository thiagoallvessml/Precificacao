-- ============================================================
-- FIX: Garantir colunas ultimo_pagamento_id e ultimo_pagamento_em
-- Execute no Supabase SQL Editor
-- ============================================================

-- 1. Adicionar colunas caso ainda não existam
ALTER TABLE public.perfis_usuarios
    ADD COLUMN IF NOT EXISTS ultimo_pagamento_id  TEXT,
    ADD COLUMN IF NOT EXISTS ultimo_pagamento_em  TIMESTAMPTZ;

-- 2. Verificar colunas existentes
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'perfis_usuarios'
  AND column_name IN ('ultimo_pagamento_id', 'ultimo_pagamento_em', 'plano', 'premium_inicio');

-- 3. Ver estado atual dos usuários (diagnóstico)
SELECT
    id,
    email,
    plano,
    premium_inicio,
    ultimo_pagamento_id,
    ultimo_pagamento_em
FROM public.perfis_usuarios
ORDER BY created_at DESC
LIMIT 20;

SELECT '✅ Colunas verificadas/criadas com sucesso!' AS resultado;
