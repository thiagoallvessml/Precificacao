/**
 * plan-limits.js
 * Limites por plano: basic, intermediario, avancado
 */

import { getSupabase } from './supabase-client.js';

// Infinity = sem limite (todos os planos ilimitados)
const LIMITES_POR_PLANO = {
    basic: {
        produtos: Infinity,
        receitas: Infinity,
        marketplaces: Infinity,
        vendas: Infinity,
        categorias_produtos: Infinity,
        categorias_insumos: Infinity,
        categorias_despesas: Infinity,
    },
    intermediario: {
        produtos: Infinity,
        receitas: Infinity,
        marketplaces: Infinity,
        vendas: Infinity,
        categorias_produtos: Infinity,
        categorias_insumos: Infinity,
        categorias_despesas: Infinity,
    },
    avancado: {
        produtos: Infinity,
        receitas: Infinity,
        marketplaces: Infinity,
        vendas: Infinity,
        categorias_produtos: Infinity,
        categorias_insumos: Infinity,
        categorias_despesas: Infinity,
    },
    // Legado
    free: null, // usa basic
    premium: null, // usa avancado
};

/**
 * Retorna os limites do plano atual
 * @param {string} plano
 * @returns {object}
 */
function getLimites(plano) {
    if (plano === 'free') return LIMITES_POR_PLANO.basic;
    if (plano === 'premium') return LIMITES_POR_PLANO.avancado;
    return LIMITES_POR_PLANO[plano] || LIMITES_POR_PLANO.basic;
}

/**
 * Busca o plano e info de trial do usuário logado
 */
export async function getTrialInfo() {
    const supabase = getSupabase();
    if (!supabase) return { plano: 'basic', emTrial: false, diasRestantes: 0, trialExpira: null };

    try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session) return { plano: 'basic', emTrial: false, diasRestantes: 0, trialExpira: null };

        const { data: perfil } = await supabase
            .from('perfis_usuarios')
            .select('plano, trial_expires_at')
            .eq('id', session.user.id)
            .single();

        const plano = perfil?.plano || 'basic';
        const trialExpira = perfil?.trial_expires_at ? new Date(perfil.trial_expires_at) : null;
        const agora = new Date();
        const emTrial = trialExpira ? trialExpira > agora : false;
        const diasRestantes = emTrial
            ? Math.ceil((trialExpira - agora) / (1000 * 60 * 60 * 24))
            : 0;

        return { plano, emTrial, diasRestantes, trialExpira };
    } catch (e) {
        console.warn('plan-limits: erro ao buscar trial info:', e);
        return { plano: 'basic', emTrial: false, diasRestantes: 0, trialExpira: null };
    }
}

/**
 * Busca o plano efetivo do usuário (considera trial)
 * @returns {Promise<string>} 'basic' | 'intermediario' | 'avancado'
 */
export async function getUserPlan() {
    try {
        const { plano, emTrial, trialExpira } = await getTrialInfo();

        // Trial ativo = acesso avançado completo
        if (emTrial) return 'avancado';

        // Trial expirou sem pagamento:
        // Só retorna 'free' (bloqueado) se o plano no banco ainda for 'free',
        // significando que nunca houve assinatura.
        // Se o plano for 'basic', 'intermediario', 'avancado', etc., o usuário pagou.
        const trialJaExistiu = trialExpira !== null;
        if (trialJaExistiu && !emTrial && plano === 'free') return 'free';

        // Normalizar legado: 'premium' → 'avancado'
        if (plano === 'premium') return 'avancado';

        return plano || 'basic';
    } catch (e) {
        console.warn('plan-limits: erro ao buscar plano:', e);
        return 'basic';
    }
}

/**
 * Conta registros de uma tabela
 * @param {string} tabela
 * @param {object} filtros - filtros opcionais { coluna: valor }
 * @returns {Promise<number>}
 */
async function contarRegistros(tabela, filtros = {}) {
    const supabase = getSupabase();
    if (!supabase) return 0;

    try {
        let query = supabase.from(tabela).select('id', { count: 'exact', head: true });

        Object.entries(filtros).forEach(([col, val]) => {
            query = query.eq(col, val);
        });

        const { count, error } = await query;
        if (error) throw error;
        return count || 0;
    } catch (e) {
        console.warn(`plan-limits: erro ao contar ${tabela}:`, e);
        return 0;
    }
}

/**
 * Conta vendas do mês atual
 * @returns {Promise<number>}
 */
async function contarVendasMes() {
    const supabase = getSupabase();
    if (!supabase) return 0;

    try {
        const agora = new Date();
        const inicioMes = new Date(agora.getFullYear(), agora.getMonth(), 1).toISOString();
        const fimMes = new Date(agora.getFullYear(), agora.getMonth() + 1, 0, 23, 59, 59).toISOString();

        const { count, error } = await supabase
            .from('pedidos')
            .select('id', { count: 'exact', head: true })
            .gte('data_pedido', inicioMes)
            .lte('data_pedido', fimMes);

        if (error) throw error;
        return count || 0;
    } catch (e) {
        console.warn('plan-limits: erro ao contar vendas:', e);
        return 0;
    }
}

/**
 * Cria o HTML do banner de limite
 */
function criarBanner(atual, limite, recurso, icone) {
    const porcentagem = Math.min((atual / limite) * 100, 100);
    const atingiu = atual >= limite;
    const quase = porcentagem >= 70;

    const corBarra = atingiu ? 'bg-red-500' : quase ? 'bg-amber-500' : 'bg-primary';
    const corTexto = atingiu ? 'text-red-400' : quase ? 'text-amber-400' : 'text-primary';
    const corBg = atingiu ? 'border-red-500/30 bg-red-500/5' : quase ? 'border-amber-500/30 bg-amber-500/5' : 'border-primary/20 bg-primary/5';

    return `
        <div class="plan-limit-banner ${corBg} border rounded-xl p-3 flex items-center gap-3 transition-all" style="animation: fadeInBanner 0.3s ease-out">
            <div class="flex items-center gap-2 shrink-0">
                <span class="material-symbols-outlined text-lg ${corTexto}">${icone}</span>
            </div>
            <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between mb-1">
                    <span class="text-xs font-semibold text-white">${recurso}</span>
                    <span class="text-[10px] font-bold ${corTexto}">${atual}/${limite}</span>
                </div>
                <div class="w-full h-1.5 bg-white/10 rounded-full overflow-hidden">
                    <div class="${corBarra} h-full rounded-full transition-all" style="width: ${porcentagem}%"></div>
                </div>
                ${atingiu ? `
                    <p class="text-[10px] text-red-400 mt-1 font-medium">
                        Limite atingido · <a href="planos.html" class="underline hover:text-red-300">Fazer upgrade</a>
                    </p>
                ` : ''}
            </div>
        </div>
    `;
}

/**
 * Insere o CSS de animação no documento
 */
function injetarCSS() {
    if (document.getElementById('plan-limits-css')) return;

    const style = document.createElement('style');
    style.id = 'plan-limits-css';
    style.textContent = `
        @keyframes fadeInBanner {
            from { opacity: 0; transform: translateY(-8px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .plan-limit-banner {
            font-family: 'Work Sans', sans-serif;
        }
    `;
    document.head.appendChild(style);
}

/**
 * Verifica e mostra banner de limite para produtos
 */
export async function checkLimiteProdutos(container) {
    const plano = await getUserPlan();
    const limites = getLimites(plano);
    if (limites.produtos === Infinity) return { atual: 0, limite: Infinity, atingiu: false };

    const atual = await contarRegistros('produtos');
    const limite = limites.produtos;

    injetarCSS();
    const bannerHTML = criarBanner(atual, limite, 'Produtos cadastrados', 'icecream');
    if (container) container.insertAdjacentHTML('afterbegin', bannerHTML);

    return { atual, limite, atingiu: atual >= limite };
}

/**
 * Verifica e mostra banner de limite para receitas
 */
export async function checkLimiteReceitas(container) {
    const plano = await getUserPlan();
    const limites = getLimites(plano);
    if (limites.receitas === Infinity) return { atual: 0, limite: Infinity, atingiu: false };

    const atual = await contarRegistros('receitas', { ativo: true });
    const limite = limites.receitas;

    injetarCSS();
    const bannerHTML = criarBanner(atual, limite, 'Receitas cadastradas', 'menu_book');
    if (container) container.insertAdjacentHTML('afterbegin', bannerHTML);

    return { atual, limite, atingiu: atual >= limite };
}

/**
 * Verifica e mostra banner de limite para marketplaces
 */
export async function checkLimiteMarketplaces(container) {
    const plano = await getUserPlan();
    const limites = getLimites(plano);
    if (limites.marketplaces === Infinity) return { atual: 0, limite: Infinity, atingiu: false };

    const atual = await contarRegistros('categorias', { tipo: 'marketplace', ativo: true });
    const limite = limites.marketplaces;

    injetarCSS();
    const bannerHTML = criarBanner(atual, limite, 'Marketplace ativo', 'storefront');
    if (container) container.insertAdjacentHTML('afterbegin', bannerHTML);

    return { atual, limite, atingiu: atual >= limite };
}

/**
 * Verifica e mostra banner de limite para vendas manuais (mensal)
 */
export async function checkLimiteVendas(container) {
    const plano = await getUserPlan();
    const limites = getLimites(plano);
    if (limites.vendas === Infinity) return { atual: 0, limite: Infinity, atingiu: false };

    const atual = await contarVendasMes();
    const limite = limites.vendas;

    const mesAtual = new Date().toLocaleDateString('pt-BR', { month: 'long' });

    injetarCSS();
    const bannerHTML = criarBanner(atual, limite, `Vendas em ${mesAtual}`, 'shopping_cart');
    if (container) container.insertAdjacentHTML('afterbegin', bannerHTML);

    return { atual, limite, atingiu: atual >= limite };
}

/**
 * Retorna os limites do plano Free (agora retorna limites do plano atual)
 * @deprecated Use getLimites(plano) diretamente
 */
export function getFreeLimits() {
    return { ...LIMITES_POR_PLANO.basic };
}

/**
 * Verifica e mostra banner de limite para categorias por tipo
 * @param {string} tipo - 'produtos', 'insumos' ou 'despesas'
 * @param {HTMLElement} container
 */
export async function checkLimiteCategorias(tipo, container) {
    const plano = await getUserPlan();
    const limites = getLimites(plano);

    const limiteKey = `categorias_${tipo}`;
    const limite = limites[limiteKey];

    // Sem limite para este plano
    if (!limite || limite === Infinity) return { atual: 0, limite: Infinity, atingiu: false };

    const atual = await contarRegistros('categorias', { tipo: tipo, ativo: true });

    const icones = {
        produtos: 'icecream',
        insumos: 'inventory_2',
        despesas: 'receipt_long'
    };

    const nomes = {
        produtos: 'Categorias de Produtos',
        insumos: 'Categorias de Insumos',
        despesas: 'Categorias de Despesas'
    };

    injetarCSS();
    const bannerHTML = criarBanner(atual, limite, nomes[tipo] || 'Categorias', icones[tipo] || 'category');
    if (container) {
        container.innerHTML = '';
        container.insertAdjacentHTML('afterbegin', bannerHTML);
    }

    return { atual, limite, atingiu: atual >= limite };
}
