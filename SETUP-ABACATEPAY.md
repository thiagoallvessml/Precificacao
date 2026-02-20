# 🔧 Guia de Configuração — AbacatePay + Supabase Edge Functions

Para não expor a chave de API no frontend, usamos um proxy seguro
que guarde a chave da AbacatePay. Vamos usar **Supabase Edge Functions** para isso.

## Fluxo da Integração

```
Frontend (checkout) → Edge Function (create-pix-charge) → AbacatePay API
Frontend (polling)  → Edge Function (check-pix-status)  → AbacatePay API
```

---

## Passo 1: Obter sua chave de API da AbacatePay

1. Acesse o **Dashboard da AbacatePay**: https://app.abacatepay.com
2. Vá em **Configurações → Chaves de API**
3. Copie sua chave de API (Bearer Token)
4. A chave tem o formato: `abc_live_xxxxxxxxxxxx`

---

## Passo 2: Configurar Supabase Edge Functions

### 2.1 — Instalar o CLI do Supabase
```bash
npm install -g supabase
```

### 2.2 — Fazer login no Supabase
```bash
npx supabase login
```

### 2.3 — Linkar o projeto
```bash
npx supabase link --project-ref SEU_PROJECT_REF
```

### 2.4 — Criar as Edge Functions

**Criar a função de criar cobrança:**
```bash
npx supabase functions new create-pix-charge
```
→ Cole o conteúdo de `supabase-edge-functions/create-pix-charge.js`

**Criar a função de checar status:**
```bash
npx supabase functions new check-pix-status
```
→ Cole o conteúdo de `supabase-edge-functions/check-pix-status.js`

### 2.5 — Configurar o secret da AbacatePay

```bash
npx supabase secrets set ABACATEPAY_API_KEY=SUA_CHAVE_ABACATEPAY_AQUI
```

### 2.6 — Deploy das funções

```bash
npx supabase functions deploy create-pix-charge --no-verify-jwt
npx supabase functions deploy check-pix-status --no-verify-jwt
```

---

## Passo 3: Configurar no Frontend

Abra o arquivo `supabase-config.js` e substitua:

```javascript
const ABACATEPAY_API_KEY = 'SUA_CHAVE_ABACATEPAY_AQUI';
const ABACATEPAY_API_URL = 'https://api.abacatepay.com/v1';
```

> **⚠️ MODO DIRETO vs EDGE FUNCTIONS:**
> - Para testes rápidos, a chave pode ficar no frontend (supabase-config.js)
> - Para produção, use as Edge Functions como proxy (mais seguro)

---

## Passo 4: Testar

1. Abra a página de checkout
2. Escolha um plano
3. Na tela de pagamento Pix:
   - O QR Code deve ser gerado pela AbacatePay
   - O código Pix copia-e-cola deve funcionar
   - O polling automático verifica se o pagamento foi feito

---

## Referência da API AbacatePay

### Criar cobrança (billing)
```
POST https://api.abacatepay.com/v1/billing/create
Authorization: Bearer SUA_CHAVE

{
  "frequency": "ONE_TIME",
  "methods": ["PIX"],
  "products": [{
    "externalId": "plano-premium-123",
    "name": "Plano Premium Mensal",
    "quantity": 1,
    "price": 3990
  }]
}
```

### Consultar status
```
GET https://api.abacatepay.com/v1/billing/get?id=BILLING_ID
Authorization: Bearer SUA_CHAVE
```

### Notas importantes
- O valor na AbacatePay é em **centavos** (R$ 39,90 = 3990)
- O `frequency` pode ser `ONE_TIME` ou `RECURRING`
- O campo `methods` aceita `["PIX"]` ou `["CARD"]`
- A resposta inclui QR Code e código Pix copia-e-cola
- Status possíveis: `PENDING`, `PAID`, `EXPIRED`, `CANCELLED`

---

## Webhooks (Opcional / Avançado)

Para receber notificações automáticas de pagamento:

1. No Dashboard AbacatePay, configure webhooks
2. Eventos disponíveis: `billing.paid`, `pix.paid`, `pix.expired`
3. Valide a assinatura do webhook recebido
