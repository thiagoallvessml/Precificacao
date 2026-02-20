// Configuração do Supabase
// As credenciais são lidas de variáveis de ambiente (VITE_*)
// Configure no painel da Vercel: Settings > Environment Variables

// Para desenvolvimento local, crie um arquivo .env.local na raiz:
// VITE_SUPABASE_URL=https://seu-projeto.supabase.co
// VITE_SUPABASE_ANON_KEY=sua-chave-anon
// VITE_ABACATEPAY_API_KEY=sua-chave-abacatepay

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || '';
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

// URL base para Edge Functions (proxy seguro para AbacatePay)
const SUPABASE_FUNCTIONS_URL = SUPABASE_URL ? `${SUPABASE_URL}/functions/v1` : '';

// ============================================================
// CONFIGURAÇÃO ABACATEPAY
// ============================================================
const ABACATEPAY_API_KEY = import.meta.env.VITE_ABACATEPAY_API_KEY || '';
const ABACATEPAY_API_URL = import.meta.env.VITE_ABACATEPAY_API_URL || 'https://api.abacatepay.com/v1';

export { SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_FUNCTIONS_URL, ABACATEPAY_API_KEY, ABACATEPAY_API_URL };
