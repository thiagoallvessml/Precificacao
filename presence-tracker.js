/**
 * Presence Tracker - Rastreia usuários online via Supabase Realtime Presence
 * 
 * Uso em qualquer página:
 *   import './presence-tracker.js';
 * 
 * Uso no admin dashboard para monitorar:
 *   import { getPresenceChannel, countOnlineUsers } from './presence-tracker.js';
 *   const channel = getPresenceChannel();
 *   channel.on('presence', { event: 'sync' }, () => { ... });
 */

import { getSupabase } from './supabase-client.js';

let presenceChannel = null;

/**
 * Inicializa o tracking de presença do usuário atual
 */
async function initPresence() {
    const supabase = getSupabase();
    if (!supabase) return;

    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return;

        // Criar canal de presença
        presenceChannel = supabase.channel('online-users', {
            config: {
                presence: {
                    key: user.id,
                },
            },
        });

        // Registrar presença
        presenceChannel
            .on('presence', { event: 'sync' }, () => {
                // Presença sincronizada
            })
            .subscribe(async (status) => {
                if (status === 'SUBSCRIBED') {
                    await presenceChannel.track({
                        user_id: user.id,
                        email: user.email,
                        online_at: new Date().toISOString(),
                        page: window.location.pathname.split('/').pop() || 'index.html'
                    });
                }
            });

        // Cleanup ao sair da página
        window.addEventListener('beforeunload', () => {
            if (presenceChannel) {
                presenceChannel.untrack();
            }
        });

    } catch (error) {
        // Silencioso - presença é opcional, não deve quebrar a página
        console.warn('Presence tracker:', error.message);
    }
}

/**
 * Retorna o canal de presença para monitoramento
 * @returns {object|null}
 */
export function getPresenceChannel() {
    return presenceChannel;
}

/**
 * Conta quantos usuários estão online agora
 * @returns {number}
 */
export function countOnlineUsers() {
    if (!presenceChannel) return 0;
    const state = presenceChannel.presenceState();
    return Object.keys(state).length;
}

/**
 * Retorna lista de usuários online com detalhes
 * @returns {Array}
 */
export function getOnlineUsers() {
    if (!presenceChannel) return [];
    const state = presenceChannel.presenceState();
    const users = [];
    for (const [key, presences] of Object.entries(state)) {
        if (presences && presences.length > 0) {
            users.push({
                user_id: key,
                ...presences[0]
            });
        }
    }
    return users;
}

// Auto-inicializar
initPresence();
