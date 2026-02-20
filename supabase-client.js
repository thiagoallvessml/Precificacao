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
        if (SUPABASE_URL === 'SUA_URL_AQUI' || SUPABASE_ANON_KEY === 'SUA_CHAVE_ANON_AQUI') {
            console.error('⚠️ Por favor, configure suas credenciais do Supabase no arquivo supabase-config.js');
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

// Exporta o cliente como padrão
export default getSupabase;
