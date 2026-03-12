/**
 * analytics-tracker.js
 * Registra page views automaticamente no Supabase.
 * Basta importar em qualquer página: import './analytics-tracker.js'
 */

import { getSupabase } from './supabase-client.js';

(async () => {
    try {
        const supabase = getSupabase();
        if (!supabase) return;

        // Gerar ou recuperar session_id (por tab/session)
        let sessionId = sessionStorage.getItem('_pv_session');
        if (!sessionId) {
            sessionId = crypto.randomUUID();
            sessionStorage.setItem('_pv_session', sessionId);
        }

        // Página atual (só o nome do arquivo)
        const page = window.location.pathname.split('/').pop() || 'index.html';

        // Referrer (página anterior dentro do site)
        const referrer = document.referrer
            ? new URL(document.referrer).pathname.split('/').pop()
            : null;

        // Usuário logado (opcional)
        const { data: { session } } = await supabase.auth.getSession();
        const userId = session?.user?.id || null;

        await supabase.from('page_views').insert([{
            page,
            user_id: userId,
            session_id: sessionId,
            referrer,
            user_agent: navigator.userAgent.substring(0, 200)
        }]);

    } catch (e) {
        // Silencioso — não atrapalha o usuário
        console.debug('[analytics] Erro ao registrar view:', e.message);
    }
})();
