// Supabase Edge Function: create-pix-charge
// Cole este código no Supabase Dashboard > Edge Functions > New Function
// Nome da função: create-pix-charge

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const ABACATEPAY_API_URL = "https://api.abacatepay.com/v1";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req) => {
    // Handle CORS preflight
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        // Pegar a chave da AbacatePay dos secrets do Supabase
        const ABACATEPAY_API_KEY = Deno.env.get("ABACATEPAY_API_KEY");

        if (!ABACATEPAY_API_KEY) {
            return new Response(
                JSON.stringify({ error: "ABACATEPAY_API_KEY não configurada" }),
                { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        const body = await req.json();
        const { amount, description, name, email, cellphone, taxId, expiresIn } = body;

        // Validar valor mínimo
        if (!amount || amount < 100) {
            return new Response(
                JSON.stringify({ error: "Valor mínimo é R$ 1,00 (100 centavos)" }),
                { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Criar cobrança na AbacatePay
        const billingPayload = {
            frequency: "ONE_TIME",
            methods: ["PIX"],
            products: [{
                externalId: `plano-premium-${Date.now()}`,
                name: description || "Plano Premium",
                quantity: 1,
                price: amount, // AbacatePay usa centavos
            }],
        };

        // Campos opcionais
        if (expiresIn) billingPayload.expiresIn = expiresIn;
        if (description) billingPayload.description = description;

        // Cliente (se fornecido)
        if (name && email && cellphone && taxId) {
            billingPayload.customer = { name, email, cellphone, taxId };
        }

        const response = await fetch(`${ABACATEPAY_API_URL}/billing/create`, {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${ABACATEPAY_API_KEY}`,
                "Content-Type": "application/json",
            },
            body: JSON.stringify(billingPayload),
        });

        const data = await response.json();

        return new Response(
            JSON.stringify(data),
            {
                status: response.status,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            }
        );
    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    }
});
