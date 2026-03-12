/**
 * api/abacatepay-webhook.js
 * Vercel Serverless Function — Webhook da AbacatePay
 *
 * Fluxo:
 *   AbacatePay → POST /api/abacatepay-webhook → Supabase (atualiza plano do usuário)
 *
 * Configure no painel da AbacatePay:
 *   Webhook URL: https://precificax.com.br/api/abacatepay-webhook
 *   Eventos: billing.paid, pixQrCode.paid
 */

import { createClient } from '@supabase/supabase-js';

// Mapear plano do metadata do billing para o nome interno
const PLANO_MAP = {
    'basic': 'basic',
    'intermediario': 'intermediario',
    'avancado': 'avancado',
    'premium': 'avancado',
    'mensal': 'avancado',
    'anual': 'avancado',
};

export default async function handler(req, res) {
    // CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-AbacatePay-Signature');

    if (req.method === 'OPTIONS') return res.status(200).end();
    if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

    // ── 1. Validar assinatura do webhook (segurança) ──────────────────────────
    const WEBHOOK_SECRET = process.env.ABACATEPAY_WEBHOOK_SECRET;
    if (WEBHOOK_SECRET) {
        const signature = req.headers['x-abacatepay-signature'] || req.headers['x-webhook-token'];
        if (signature !== WEBHOOK_SECRET) {
            console.warn('❌ Webhook: assinatura inválida');
            return res.status(401).json({ error: 'Unauthorized' });
        }
    }

    // ── 2. Ler payload ────────────────────────────────────────────────────────
    const body = req.body;
    console.log('📩 AbacatePay Webhook recebido:', JSON.stringify(body));

    const event = body?.event || body?.type || '';
    const data = body?.data || body;

    // Aceitar eventos de pagamento confirmado (Pix ou Billing)
    const isPaid =
        event === 'billing.paid' ||
        event === 'pixQrCode.paid' ||
        event === 'pix.paid' ||
        data?.status === 'PAID' ||
        data?.status === 'paid';

    if (!isPaid) {
        console.log(`ℹ️ Evento ignorado: ${event} (status: ${data?.status})`);
        return res.status(200).json({ ok: true, message: 'Evento não processado' });
    }

    // ── 3. Extrair dados do pagamento ─────────────────────────────────────────
    // A AbacatePay envia dados no campo `data` ou diretamente no body
    const metadata = data?.metadata || data?.customer?.metadata || {};
    const customerEmail = data?.customer?.email || data?.email || metadata?.email;
    const planoRecebido = data?.metadata?.plano || data?.products?.[0]?.externalId || 'avancado';
    const billingId = data?.id || data?.billingId;

    console.log(`✅ Pagamento confirmado! Email: ${customerEmail} | Plano: ${planoRecebido} | ID: ${billingId}`);

    if (!customerEmail) {
        console.error('❌ Email do cliente não encontrado no webhook');
        return res.status(400).json({ error: 'Customer email missing' });
    }

    // ── 4. Conectar ao Supabase com service_role (acesso admin) ───────────────
    const SUPABASE_URL = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.VITE_SUPABASE_URL;
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
        console.error('❌ Variáveis do Supabase não configuradas');
        return res.status(500).json({ error: 'Supabase not configured' });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    try {
        // ── 5. Obter user_id: preferencialmente do metadata, senão fallback por email ──
        let userId = data?.metadata?.user_id || null;

        if (userId) {
            console.log(`✅ user_id obtido do metadata: ${userId}`);
        } else {
            // Fallback: buscar na tabela perfis_usuarios pelo email
            console.log(`⚠️ user_id não veio no metadata, buscando pelo email: ${customerEmail}`);
            const { data: perfis, error: perfisErr } = await supabase
                .from('perfis_usuarios')
                .select('id')
                .eq('email', customerEmail)
                .limit(1);

            console.log('🔍 perfis_usuarios result:', JSON.stringify(perfis), 'error:', JSON.stringify(perfisErr));

            if (perfis && perfis.length > 0) {
                userId = perfis[0].id;
                console.log(`✅ user_id encontrado via perfis_usuarios: ${userId}`);
            }
        }

        if (!userId) {
            console.error(`❌ Não foi possível identificar o usuário para: ${customerEmail}`);
            return res.status(404).json({ error: 'User not found', email: customerEmail, tip: 'user_id missing from metadata' });
        }

        const planoFinal = PLANO_MAP[planoRecebido?.toLowerCase()] || 'avancado';

        // ── 6. Calcular data de expiração do plano (30 dias) ──────────────────
        const planoExpira = new Date();
        planoExpira.setDate(planoExpira.getDate() + 30);

        // ── 7. Atualizar plano no perfil do usuário ───────────────────────────
        const { error: updateErr } = await supabase
            .from('perfis_usuarios')
            .update({
                plano: planoFinal,
                premium_inicio: new Date().toISOString(),
                ultimo_pagamento_id: billingId || null,
                ultimo_pagamento_em: new Date().toISOString(),
            })
            .eq('id', userId);

        if (updateErr) {
            console.error('❌ Erro ao atualizar plano:', JSON.stringify(updateErr));
            throw updateErr;
        }

        console.log(`✅ Plano '${planoFinal}' ativado para userId=${userId} (${customerEmail})`);

        // ── 8. Registrar histórico de pagamento (opcional) ────────────────────
        try {
            await supabase.from('pagamentos').insert([{
                user_id: userId,
                billing_id: billingId,
                plano: planoFinal,
                status: 'pago',
                valor: data?.amount ? data.amount / 100 : null,
                metodo: 'pix',
                created_at: new Date().toISOString(),
            }]);
        } catch (e) {
            console.warn('⚠️ Histórico de pagamento não registrado (tabela pode não existir):', e.message);
        }

        return res.status(200).json({
            ok: true,
            message: `Plano '${planoFinal}' ativado`,
            userId,
            plano: planoFinal,
        });

    } catch (err) {
        console.error('❌ Erro no webhook:', err.message);
        return res.status(500).json({ error: err.message });
    }
}
