/**
 * plan-limits.js
 * Módulo centralizado de limites do plano Free
 * 
 * Limites Free:
 * - Produtos: 7
 * - Receitas: 5
 * - Marketplaces: 1
 * - Vendas manuais: 30 (por mês)
 */

import { getSupabase } from './supabase-client.js';

const FREE_LIMITS = {
    produtos: 3,
    receitas: 2,
    marketplaces: 1,
    vendas: 30,  // por mês
    // Limites de categorias por tipo
    categorias_produtos: 2,
    categorias_insumos: 2,
    categorias_despesas: 3
};

/**
 * Busca o plano do usuário logado
 * @returns {Promise<string>} 'free' ou 'premium'
 */
export async function getUserPlan() {
    const supabase = getSupabase();
    if (!supabase) return 'free';

    try {
        // Tentar via RPC
        const { data: rpcRole } = await supabase.rpc('get_user_role');

        const { data: { session } } = await supabase.auth.getSession();
        if (!session) return 'free';

        const { data: perfil } = await supabase
            .from('perfis_usuarios')
            .select('plano')
            .eq('id', session.user.id)
            .single();

        return perfil?.plano || 'free';
    } catch (e) {
        console.warn('plan-limits: erro ao buscar plano:', e);
        return 'free';
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
 * @param {HTMLElement} container - elemento onde inserir o banner
 * @returns {Promise<{atual: number, limite: number, atingiu: boolean}>}
 */
export async function checkLimiteProdutos(container) {
    const plano = await getUserPlan();
    if (plano === 'premium') return { atual: 0, limite: Infinity, atingiu: false };

    const atual = await contarRegistros('produtos');
    const limite = FREE_LIMITS.produtos;

    injetarCSS();
    const bannerHTML = criarBanner(atual, limite, 'Produtos cadastrados', 'icecream');
    if (container) container.insertAdjacentHTML('afterbegin', bannerHTML);

    return { atual, limite, atingiu: atual >= limite };
}

/**
 * Verifica e mostra banner de limite para receitas
 * @param {HTMLElement} container
 * @returns {Promise<{atual: number, limite: number, atingiu: boolean}>}
 */
export async function checkLimiteReceitas(container) {
    const plano = await getUserPlan();
    if (plano === 'premium') return { atual: 0, limite: Infinity, atingiu: false };

    const atual = await contarRegistros('receitas', { ativo: true });
    const limite = FREE_LIMITS.receitas;

    injetarCSS();
    const bannerHTML = criarBanner(atual, limite, 'Receitas cadastradas', 'menu_book');
    if (container) container.insertAdjacentHTML('afterbegin', bannerHTML);

    return { atual, limite, atingiu: atual >= limite };
}

/**
 * Verifica e mostra banner de limite para marketplaces
 * @param {HTMLElement} container
 * @returns {Promise<{atual: number, limite: number, atingiu: boolean}>}
 */
export async function checkLimiteMarketplaces(container) {
    const plano = await getUserPlan();
    if (plano === 'premium') return { atual: 0, limite: Infinity, atingiu: false };

    const atual = await contarRegistros('categorias', { tipo: 'marketplace', ativo: true });
    const limite = FREE_LIMITS.marketplaces;

    injetarCSS();
    const bannerHTML = criarBanner(atual, limite, 'Marketplace ativo', 'storefront');
    if (container) container.insertAdjacentHTML('afterbegin', bannerHTML);

    return { atual, limite, atingiu: atual >= limite };
}

/**
 * Verifica e mostra banner de limite para vendas manuais (mensal)
 * @param {HTMLElement} container
 * @returns {Promise<{atual: number, limite: number, atingiu: boolean}>}
 */
export async function checkLimiteVendas(container) {
    const plano = await getUserPlan();
    if (plano === 'premium') return { atual: 0, limite: Infinity, atingiu: false };

    const atual = await contarVendasMes();
    const limite = FREE_LIMITS.vendas;

    const mesAtual = new Date().toLocaleDateString('pt-BR', { month: 'long' });

    injetarCSS();
    const bannerHTML = criarBanner(atual, limite, `Vendas em ${mesAtual}`, 'shopping_cart');
    if (container) container.insertAdjacentHTML('afterbegin', bannerHTML);

    return { atual, limite, atingiu: atual >= limite };
}

/**
 * Retorna os limites do plano Free
 */
export function getFreeLimits() {
    return { ...FREE_LIMITS };
}

/**
 * Verifica e mostra banner de limite para categorias por tipo
 * @param {string} tipo - 'produtos', 'insumos' ou 'despesas'
 * @param {HTMLElement} container - elemento onde inserir o banner
 * @returns {Promise<{atual: number, limite: number, atingiu: boolean}>}
 */
export async function checkLimiteCategorias(tipo, container) {
    const plano = await getUserPlan();
    if (plano === 'premium') return { atual: 0, limite: Infinity, atingiu: false };

    const limiteKey = `categorias_${tipo}`;
    const limite = FREE_LIMITS[limiteKey];
    if (!limite) return { atual: 0, limite: Infinity, atingiu: false };

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
