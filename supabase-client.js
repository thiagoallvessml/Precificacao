import { createClient } from '@supabase/supabase-js';
import { SUPABASE_URL, SUPABASE_ANON_KEY } from './supabase-config.js';

// Criando o cliente Supabase
let supabase = null;

/**
 * Inicializa o cliente Supabase
 * @returns {object} Cliente Supabase
 */
export function initSupabase() {
    if (!supabase) {
        // Verifica se as credenciais foram configuradas
        if (!SUPABASE_URL || !SUPABASE_ANON_KEY || SUPABASE_URL === 'SUA_URL_AQUI' || SUPABASE_ANON_KEY === 'SUA_CHAVE_ANON_AQUI') {
            console.error('⚠️ Credenciais do Supabase não configuradas!');
            console.error('   Configure as variáveis de ambiente VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY');
            console.error('   - Local: crie um arquivo .env.local na raiz do projeto');
            console.error('   - Vercel: Settings > Environment Variables');
            return null;
        }

        try {
            supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
                auth: {
                    persistSession: true,
                    autoRefreshToken: true,
                }
            });
            console.log('✅ Supabase conectado com sucesso!');

            // ── Rastrear page view automaticamente (todas as páginas) ──
            _autoTrackPageView(supabase);
        } catch (error) {
            console.error('❌ Erro ao conectar com Supabase:', error);
            return null;
        }
    }
    return supabase;
}

/**
 * Retorna o cliente Supabase (inicializa se necessário)
 * @returns {object} Cliente Supabase
 */
export function getSupabase() {
    if (!supabase) {
        return initSupabase();
    }
    return supabase;
}

/**
 * Registra uma page view de forma assíncrona e silenciosa.
 * Usa sessionStorage para evitar duplicação por página navegada.
 * @param {object} sb - Cliente Supabase já inicializado
 */
async function _autoTrackPageView(sb) {
    try {
        const page = window.location.pathname.split('/').pop() || 'index.html';

        // Evitar duplicar registro para a mesma página na mesma sessão de aba
        const flagKey = `_pv_tracked_${page}`;
        if (sessionStorage.getItem(flagKey)) return;
        sessionStorage.setItem(flagKey, '1');

        // Session ID único por aba do browser
        let sessionId = sessionStorage.getItem('_pv_session');
        if (!sessionId) {
            sessionId = crypto.randomUUID();
            sessionStorage.setItem('_pv_session', sessionId);
        }

        // Referrer (página anterior, só o nome do arquivo)
        const referrer = document.referrer
            ? new URL(document.referrer).pathname.split('/').pop()
            : null;

        // Tenta pegar user_id se logado
        let userId = null;
        try {
            const { data: { session } } = await sb.auth.getSession();
            userId = session?.user?.id || null;
        } catch (_) { /* anônimo é válido */ }

        await sb.from('page_views').insert([{
            page,
            user_id: userId,
            session_id: sessionId,
            referrer,
            user_agent: navigator.userAgent.substring(0, 200)
        }]);

    } catch (e) {
        console.debug('[analytics] view não registrada:', e?.message);
    }
}

// Exporta o cliente como padrão
export default getSupabase;

