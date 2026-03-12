/**
 * api/pix-repasse.js
 * Vercel Serverless Function — Envio automático de Pix para afiliados
 *
 * AbacatePay endpoint: POST /v1/transfer/create
 * Documentação: https://abacatepay.com/docs
 */

export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') return res.status(200).end();
    if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

    const API_KEY = process.env.ABACATEPAY_API_KEY;
    const API_URL = process.env.ABACATEPAY_API_URL || 'https://api.abacatepay.com/v1';

    if (!API_KEY) return res.status(500).json({ error: 'API key não configurada' });

    const { valor, chavePix, tipoPix, nome, descricao } = req.body;

    if (!valor || !chavePix) {
        return res.status(400).json({ error: 'valor e chavePix são obrigatórios' });
    }

    try {
        const payload = {
            amount: Math.round(Number(valor) * 100), // em centavos
            pixKey: chavePix,
            pixKeyType: tipoPix || 'email', // email | cpf | cnpj | phone | random
            description: descricao || `Repasse afiliado PrecificaX - ${nome || ''}`.trim(),
        };

        console.log('💸 Enviando repasse Pix:', JSON.stringify(payload));

        const response = await fetch(`${API_URL}/transfer/create`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${API_KEY}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(payload),
        });

        const data = await response.json();
        console.log('🔍 Resposta AbacatePay:', response.status, JSON.stringify(data));

        if (!response.ok) {
            return res.status(response.status).json({
                error: data?.message || data?.error || 'Erro ao processar transferência',
                details: data,
            });
        }

        return res.status(200).json({
            ok: true,
            transferId: data?.id || data?.transferId,
            status: data?.status || 'processing',
            data,
        });

    } catch (err) {
        console.error('❌ Erro no repasse:', err.message);
        return res.status(500).json({ error: err.message });
    }
}
