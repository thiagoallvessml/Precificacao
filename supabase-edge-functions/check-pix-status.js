// Supabase Edge Function: check-pix-status
// Cole este código no Supabase Dashboard > Edge Functions > New Function
// Nome da função: check-pix-status

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
        const ABACATEPAY_API_KEY = Deno.env.get("ABACATEPAY_API_KEY");

        if (!ABACATEPAY_API_KEY) {
            return new Response(
                JSON.stringify({ error: "ABACATEPAY_API_KEY não configurada" }),
                { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        const body = await req.json();
        const { billingId } = body;

        if (!billingId) {
            return new Response(
                JSON.stringify({ error: "billingId é obrigatório" }),
                { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Buscar status da cobrança na AbacatePay
        const response = await fetch(`${ABACATEPAY_API_URL}/billing/get?id=${billingId}`, {
            method: "GET",
            headers: {
                "Authorization": `Bearer ${ABACATEPAY_API_KEY}`,
                "Content-Type": "application/json",
            },
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
