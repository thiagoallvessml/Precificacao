// Vercel Serverless Function — Proxy para AbacatePay (checar status do Pix)
// Evita problemas de CORS ao chamar a API da AbacatePay diretamente do frontend

export default async function handler(req, res) {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    if (req.method !== 'GET') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    const API_KEY = process.env.ABACATEPAY_API_KEY;
    const API_URL = process.env.ABACATEPAY_API_URL || 'https://api.abacatepay.com/v1';

    if (!API_KEY) {
        return res.status(500).json({ error: 'AbacatePay API key not configured' });
    }

    const { id } = req.query;

    if (!id) {
        return res.status(400).json({ error: 'Missing id parameter' });
    }

    try {
        const response = await fetch(`${API_URL}/pixQrCode/check?id=${encodeURIComponent(id)}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${API_KEY}`,
            },
        });

        const data = await response.json();
        return res.status(response.status).json(data);
    } catch (err) {
        console.error('Erro no proxy AbacatePay:', err);
        return res.status(500).json({ error: 'Erro ao comunicar com AbacatePay', details: err.message });
    }
}
