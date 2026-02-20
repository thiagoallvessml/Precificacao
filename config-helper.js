import { getSupabase } from './supabase-client.js';

/**
 * Módulo para gerenciar configurações do sistema salvas no Supabase
 * Facilita o acesso às configurações em qualquer página da aplicação
 */

// Cache de configurações em memória (opcional, para performance)
const configCache = new Map();

/**
 * Chaves de configuração disponíveis no sistema
 */
export const CONFIG_KEYS = {
    // Produção - Gás
    PESO_GAS: 'peso_botijao_gas',
    PRECO_GAS: 'preco_botijao_gas',
    
    // Energia
    CUSTO_KWH: 'custo_kwh',
    
    // Mão de Obra
    MAO_OBRA_HORA: 'custo_mao_obra_hora',
    
    // Financeiro (já existentes no database-schema.sql)
    MARGEM_LUCRO_PADRAO: 'margem_lucro_padrao',
    MOEDA: 'moeda',
    TIMEZONE: 'timezone'
};

/**
 * Busca uma configuração específica por chave
 * @param {string} chave - Chave da configuração (use CONFIG_KEYS)
 * @param {boolean} useCache - Se true, usa cache em memória (padrão: true)
 * @returns {Promise<string|null>} Valor da configuração ou null se não encontrada
 */
export async function getConfig(chave, useCache = true) {
    // Verifica cache primeiro
    if (useCache && configCache.has(chave)) {
        return configCache.get(chave);
    }

    const supabase = getSupabase();
    if (!supabase) {
        console.error('Supabase não configurado');
        return null;
    }

    try {
        const { data, error } = await supabase
            .from('configuracoes')
            .select('valor')
            .eq('chave', chave)
            .single();

        if (error) {
            if (error.code === 'PGRST116') {
                console.warn(`Configuração '${chave}' não encontrada`);
                return null;
            }
            throw error;
        }

        // Salva no cache
        if (useCache && data) {
            configCache.set(chave, data.valor);
        }

        return data?.valor || null;
    } catch (error) {
        console.error(`Erro ao buscar configuração '${chave}':`, error);
        return null;
    }
}

/**
 * Busca uma configuração e converte para número
 * @param {string} chave - Chave da configuração
 * @param {number} defaultValue - Valor padrão se não encontrado (padrão: 0)
 * @returns {Promise<number>} Valor numérico da configuração
 */
export async function getConfigNumber(chave, defaultValue = 0) {
    const valor = await getConfig(chave);
    return parseFloat(valor) || defaultValue;
}

/**
 * Busca uma configuração e converte para boolean
 * @param {string} chave - Chave da configuração
 * @param {boolean} defaultValue - Valor padrão se não encontrado (padrão: false)
 * @returns {Promise<boolean>} Valor booleano da configuração
 */
export async function getConfigBoolean(chave, defaultValue = false) {
    const valor = await getConfig(chave);
    if (valor === null) return defaultValue;
    return valor === 'true' || valor === '1' || valor === 'yes';
}

/**
 * Busca múltiplas configurações de uma vez
 * @param {string[]} chaves - Array de chaves para buscar
 * @returns {Promise<Object>} Objeto com as configurações {chave: valor}
 */
export async function getConfigs(chaves) {
    const supabase = getSupabase();
    if (!supabase) {
        console.error('Supabase não configurado');
        return {};
    }

    try {
        const { data, error } = await supabase
            .from('configuracoes')
            .select('chave, valor')
            .in('chave', chaves);

        if (error) throw error;

        // Converte array para objeto
        const configs = {};
        data?.forEach(item => {
            configs[item.chave] = item.valor;
            configCache.set(item.chave, item.valor); // Atualiza cache
        });

        return configs;
    } catch (error) {
        console.error('Erro ao buscar múltiplas configurações:', error);
        return {};
    }
}

/**
 * Busca todas as configurações de uma categoria
 * @param {string} categoria - Categoria das configurações ('producao', 'financeiro', etc)
 * @returns {Promise<Object>} Objeto com as configurações {chave: valor}
 */
export async function getConfigsByCategory(categoria) {
    const supabase = getSupabase();
    if (!supabase) {
        console.error('Supabase não configurado');
        return {};
    }

    try {
        const { data, error } = await supabase
            .from('configuracoes')
            .select('chave, valor')
            .eq('categoria', categoria);

        if (error) throw error;

        const configs = {};
        data?.forEach(item => {
            configs[item.chave] = item.valor;
            configCache.set(item.chave, item.valor);
        });

        return configs;
    } catch (error) {
        console.error(`Erro ao buscar configurações da categoria '${categoria}':`, error);
        return {};
    }
}

/**
 * Salva ou atualiza uma configuração
 * @param {string} chave - Chave da configuração
 * @param {string|number|boolean} valor - Valor a salvar
 * @param {string} descricao - Descrição da configuração (opcional)
 * @param {string} categoria - Categoria (opcional, padrão: 'geral')
 * @returns {Promise<boolean>} true se salvou com sucesso
 */
export async function setConfig(chave, valor, descricao = null, categoria = 'geral') {
    const supabase = getSupabase();
    if (!supabase) {
        console.error('Supabase não configurado');
        return false;
    }

    try {
        // Verifica se já existe
        const { data: existing } = await supabase
            .from('configuracoes')
            .select('id')
            .eq('chave', chave)
            .single();

        const configData = {
            chave,
            valor: String(valor),
            tipo: typeof valor === 'number' ? 'number' : typeof valor === 'boolean' ? 'boolean' : 'string',
            descricao: descricao || chave,
            categoria
        };

        if (existing) {
            // Atualiza
            const { error } = await supabase
                .from('configuracoes')
                .update({ valor: String(valor), updated_at: new Date().toISOString() })
                .eq('chave', chave);

            if (error) throw error;
        } else {
            // Insere
            const { error } = await supabase
                .from('configuracoes')
                .insert([configData]);

            if (error) throw error;
        }

        // Atualiza cache
        configCache.set(chave, String(valor));
        return true;

    } catch (error) {
        console.error(`Erro ao salvar configuração '${chave}':`, error);
        return false;
    }
}

/**
 * Remove uma configuração do banco
 * @param {string} chave - Chave da configuração a remover
 * @returns {Promise<boolean>} true se removeu com sucesso
 */
export async function deleteConfig(chave) {
    const supabase = getSupabase();
    if (!supabase) {
        console.error('Supabase não configurado');
        return false;
    }

    try {
        const { error } = await supabase
            .from('configuracoes')
            .delete()
            .eq('chave', chave);

        if (error) throw error;

        // Remove do cache
        configCache.delete(chave);
        return true;

    } catch (error) {
        console.error(`Erro ao deletar configuração '${chave}':`, error);
        return false;
    }
}

/**
 * Limpa o cache de configurações em memória
 * Útil quando você sabe que as configurações foram atualizadas em outro lugar
 */
export function clearConfigCache() {
    configCache.clear();
    console.log('Cache de configurações limpo');
}

/**
 * Pré-carrega configurações comuns no cache
 * Útil para otimizar páginas que usam muitas configurações
 * @returns {Promise<void>}
 */
export async function preloadConfigs() {
    const commonKeys = [
        CONFIG_KEYS.PESO_GAS,
        CONFIG_KEYS.PRECO_GAS,
        CONFIG_KEYS.CUSTO_KWH,
        CONFIG_KEYS.MAO_OBRA_HORA,
        CONFIG_KEYS.MARGEM_LUCRO_PADRAO
    ];

    await getConfigs(commonKeys);
    console.log('Configurações comuns pré-carregadas');
}

// ========== FUNÇÕES HELPER ESPECÍFICAS ==========

/**
 * Calcula o custo do gás por kg
 * @returns {Promise<number>} Custo por kg de gás
 */
export async function getCustoGasPorKg() {
    const peso = await getConfigNumber(CONFIG_KEYS.PESO_GAS, 13);
    const preco = await getConfigNumber(CONFIG_KEYS.PRECO_GAS, 110);
    
    if (peso <= 0) return 0;
    return preco / peso;
}

/**
 * Calcula o custo de mão de obra por minuto
 * @returns {Promise<number>} Custo por minuto
 */
export async function getCustoMaoObraPorMinuto() {
    const custoHora = await getConfigNumber(CONFIG_KEYS.MAO_OBRA_HORA, 25);
    return custoHora / 60;
}

/**
 * Busca a margem de lucro padrão do sistema
 * @returns {Promise<number>} Margem de lucro em porcentagem
 */
export async function getMargemLucroPadrao() {
    return await getConfigNumber(CONFIG_KEYS.MARGEM_LUCRO_PADRAO, 30);
}

// ========== EXPORT DEFAULT ==========

export default {
    CONFIG_KEYS,
    getConfig,
    getConfigNumber,
    getConfigBoolean,
    getConfigs,
    getConfigsByCategory,
    setConfig,
    deleteConfig,
    clearConfigCache,
    preloadConfigs,
    getCustoGasPorKg,
    getCustoMaoObraPorMinuto,
    getMargemLucroPadrao
};
