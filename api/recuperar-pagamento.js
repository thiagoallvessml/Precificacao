/**
 * api/recuperar-pagamento.js
 * Re-processa um pagamento confirmado que não foi processado pela página (bug do flag)
 * 
 * POST /api/recuperar-pagamento
 * Body: { charge_id: "...", user_token: "..." }   ← token JWT do usuário logado
 */

import { createClient } from '@supabase/supabase-js';

const ABACATEPAY_API_URL = 'https://api.abacatepay.com/v1';
const ABACATEPAY_API_KEY = process.env.ABACATEPAY_API_KEY;

const PLANO_MAP = {
    'basic': 'basic',
    'intermediario': 'intermediario',
    'avancado': 'avancado',
    'premium': 'avancado',
};

export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    if (req.method === 'OPTIONS') return res.status(200).end();
    if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

    const SUPABASE_URL = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.VITE_SUPABASE_URL;
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
    if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
        return res.status(500).json({ error: 'Supabase não configurado' });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    // ── 1. Autenticar usuário via JWT ─────────────────────────────────────────
    const authHeader = req.headers.authorization || '';
    const token = authHeader.replace('Bearer ', '').trim();
    if (!token) return res.status(401).json({ error: 'Token não fornecido' });

    const { data: { user }, error: authErr } = await supabase.auth.getUser(token);
    if (authErr || !user) return res.status(401).json({ error: 'Token inválido' });

    const userId = user.id;
    const { charge_id, plano: planoBody } = req.body || {};

    if (!charge_id) return res.status(400).json({ error: 'charge_id obrigatório' });

    console.log(`🔄 Recuperando pagamento: charge_id=${charge_id} userId=${userId}`);

    try {
        // ── 2. Verificar status do pagamento na AbacatePay ────────────────────
        let chargeStatus = null;
        let chargeAmount = null;
        let chargeMetadata = {};

        if (ABACATEPAY_API_KEY) {
            try {
                const resp = await fetch(`${ABACATEPAY_API_URL}/pixQrCode/check?id=${charge_id}`, {
                    headers: { 'Authorization': `Bearer ${ABACATEPAY_API_KEY}` }
                });
                const json = await resp.json();
                chargeStatus = json.data?.status || json.status;
                chargeAmount = json.data?.amount || json.amount;
                chargeMetadata = json.data?.metadata || {};
                console.log(`📡 AbacatePay status: ${chargeStatus}`);
            } catch (e) {
                console.warn('⚠️ Não conseguiu verificar na AbacatePay:', e.message);
            }
        }

        // Se não conseguiu verificar na API mas o usuário afirma que pagou,
        // verificar se o webhook já processou (plano já foi ativado no banco)
        const { data: perfil } = await supabase
            .from('perfis_usuarios')
            .select('plano, premium_inicio, ultimo_pagamento_id, codigo_indicacao, email, nome')
            .eq('id', userId)
            .single();

        // Se o webhook já ativou o plano para este charge, apenas gerar comissão
        const webhookJaProcessou = perfil?.ultimo_pagamento_id === charge_id;

        // Aceitar se: AbacatePay confirmou PAID, ou o webhook já processou
        const isPaid = chargeStatus === 'PAID' || chargeStatus === 'paid' || chargeStatus === 'RECEIVED' || webhookJaProcessou;

        if (!isPaid && chargeStatus) {
            return res.status(400).json({
                error: `Pagamento não confirmado. Status: ${chargeStatus}`,
                charge_id
            });
        }

        // ── 3. Ativar plano (se ainda não foi pelo webhook) ───────────────────
        const planoFinal = PLANO_MAP[planoBody?.toLowerCase()] || chargeMetadata?.plano || 'basic';

        if (!webhookJaProcessou) {
            const planoExpira = new Date();
            planoExpira.setDate(planoExpira.getDate() + 30);

            const { error: upErr } = await supabase
                .from('perfis_usuarios')
                .update({
                    plano: planoFinal,
                    premium_inicio: new Date().toISOString(),
                    ultimo_pagamento_id: charge_id,
                    ultimo_pagamento_em: new Date().toISOString(),
                })
                .eq('id', userId);

            if (upErr) throw upErr;
            console.log(`✅ Plano '${planoFinal}' ativado para ${userId}`);
        } else {
            console.log(`ℹ️ Plano já ativado pelo webhook (${perfil.plano})`);
        }

        // ── 4. Verificar se já existe indicação para este charge ──────────────
        // Buscar cupom do usuário que fez a compra (pelo codigo_indicacao_origem)
        const { data: perfilAtual } = await supabase
            .from('perfis_usuarios')
            .select('indicacao_origem, nome, email')
            .eq('id', userId)
            .single();

        const cupomOrigem = perfilAtual?.indicacao_origem || chargeMetadata?.cupom;

        let comissaoGerada = false;
        let comissaoValor = 0;

        if (cupomOrigem) {
            // Buscar o cupom
            const { data: cupom } = await supabase
                .from('cupons_afiliado')
                .select('id, comissao_percentual, desconto_percentual')
                .eq('codigo', cupomOrigem)
                .eq('ativo', true)
                .single();

            if (cupom) {
                // Verificar se já existe indicação para este charge_id (evitar duplicata)
                const { data: indExist } = await supabase
                    .from('indicacoes')
                    .select('id')
                    .eq('cupom_id', cupom.id)
                    .eq('nome_indicado', perfilAtual?.nome || perfilAtual?.email || user.email)
                    .gte('data_indicacao', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()) // últimas 24h
                    .limit(1);

                if (!indExist || indExist.length === 0) {
                    // Calcular valor (charge amount em centavos → reais)
                    const valorAssinatura = chargeAmount ? chargeAmount / 100 : 0;
                    comissaoValor = valorAssinatura * ((cupom.comissao_percentual || 10) / 100);

                    const { error: indErr } = await supabase
                        .from('indicacoes')
                        .insert([{
                            cupom_id: cupom.id,
                            nome_indicado: perfilAtual?.nome || user.email,
                            status: 'ativo',
                            valor_assinatura: valorAssinatura,
                            valor_comissao: comissaoValor,
                            valor_desconto: 0,
                            data_indicacao: new Date().toISOString(),
                            data_conversao: new Date().toISOString(),
                        }]);

                    if (!indErr) {
                        comissaoGerada = true;
                        console.log(`✅ Comissão gerada: R$ ${comissaoValor.toFixed(2)} para cupom ${cupomOrigem}`);
                    } else {
                        console.error('❌ Erro ao criar indicação:', indErr);
                    }
                } else {
                    console.log('ℹ️ Indicação já existe para este pagamento');
                }
            }
        }

        return res.status(200).json({
            ok: true,
            plano: webhookJaProcessou ? perfil.plano : planoFinal,
            planoJaAtivado: webhookJaProcessou,
            comissaoGerada,
            comissaoValor,
            cupomOrigem: cupomOrigem || null,
        });

    } catch (err) {
        console.error('❌ Erro na recuperação:', err.message);
        return res.status(500).json({ error: err.message });
    }
}
