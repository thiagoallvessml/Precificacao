/**
 * Auth Guard - Proteção de páginas por autenticação e roles
 * 
 * Uso:
 *   import { protectPage, getUserProfile, requireRole } from './auth-guard.js';
 *   
 *   // Proteger página (redireciona para login se não autenticado)
 *   const perfil = await protectPage();
 *   
 *   // Proteger página com role específico (somente admin real)
 *   const perfil = await protectPage(['admin']);
 */

import { getSupabase } from './supabase-client.js';

/**
 * Mapeia roles do banco para roles de acesso do app
 * Cada role permanece como está — 'admin' é exclusivo.
 * @param {string} role
 * @returns {string}
 */
function mapRole(role) {
    // Não mapear 'dono' para 'admin' — somente role 'admin' real tem acesso administrativo
    return role;
}

/**
 * Verifica se um role é considerado admin (somente 'admin')
 * @param {string} role
 * @returns {boolean}
 */
export function isAdminRole(role) {
    return role === 'admin';
}

/**
 * Obtém o role do usuário via RPC (SECURITY DEFINER, ignora RLS)
 * @returns {Promise<string|null>}
 */
async function getRoleViaRPC(supabase) {
    try {
        const { data, error } = await supabase.rpc('get_user_role');
        if (!error && data) return data;
    } catch (e) {
        console.warn('RPC get_user_role falhou:', e);
    }
    return null;
}

/**
 * Obtém o perfil do usuário logado
 * Usa múltiplas estratégias para contornar problemas de RLS
 * @returns {Promise<object|null>} Perfil do usuário ou null
 */
export async function getUserProfile() {
    const supabase = getSupabase();
    if (!supabase) return null;

    try {
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) return null;

        // Estratégia 1: Tentar leitura direta da tabela
        try {
            const { data: perfil, error: perfilError } = await supabase
                .from('perfis_usuarios')
                .select('*')
                .eq('id', user.id)
                .single();

            if (!perfilError && perfil) {
                return {
                    ...perfil,
                    auth_email: user.email,
                    auth_id: user.id
                };
            }
        } catch (e) {
            console.warn('Leitura direta do perfil falhou:', e);
        }

        // Estratégia 2: RPC (SECURITY DEFINER, bypassa RLS)
        const role = await getRoleViaRPC(supabase);
        if (role) {
            return {
                id: user.id,
                nome: user.user_metadata?.nome || user.user_metadata?.full_name || '',
                email: user.email,
                role: role,
                ativo: true,
                auth_email: user.email,
                auth_id: user.id
            };
        }

        // Estratégia 3: user_metadata como último recurso
        const metaRole = user.user_metadata?.role;
        if (metaRole) {
            console.warn('Usando role do user_metadata como fallback:', metaRole);
            return {
                id: user.id,
                nome: user.user_metadata?.nome || user.user_metadata?.full_name || '',
                email: user.email,
                role: metaRole,
                ativo: true,
                auth_email: user.email,
                auth_id: user.id
            };
        }

        console.warn('Nenhuma estratégia funcionou para obter o perfil');
        return null;
    } catch (err) {
        console.error('Erro ao buscar perfil:', err);
        return null;
    }
}

/**
 * Protege a página: redireciona para login se não autenticado
 * @param {string[]|null} allowedRoles - Roles permitidos (null = qualquer role)
 * @param {string} redirectTo - URL de redirecionamento se não autorizado
 * @returns {Promise<object>} Perfil do usuário autenticado
 */
export async function protectPage(allowedRoles = null, redirectTo = 'login.html') {
    const supabase = getSupabase();

    if (!supabase) {
        console.warn('⚠️ Supabase não configurado, auth desativado');
        return null;
    }

    // Verificar sessão
    try {
        const { data: { session } } = await supabase.auth.getSession();

        if (!session) {
            console.log('🔒 Sem sessão, redirecionando para login...');
            window.location.href = redirectTo;
            return null;
        }
    } catch (e) {
        console.error('Erro ao verificar sessão:', e);
        window.location.href = redirectTo;
        return null;
    }

    // Buscar perfil (com fallbacks internos)
    const perfil = await getUserProfile();

    if (!perfil) {
        console.log('🔒 Perfil não encontrado, redirecionando para login...');
        // Fazer logout antes para evitar loop
        try {
            await supabase.auth.signOut();
        } catch (e) { /* ignora */ }
        window.location.href = redirectTo;
        return null;
    }

    // Verificar role (mapear dono->admin, afiliado->normal)
    const mappedRole = mapRole(perfil.role);
    if (allowedRoles && !allowedRoles.includes(perfil.role) && !allowedRoles.includes(mappedRole)) {
        console.log(`🔒 Role "${perfil.role}" (mapeado: "${mappedRole}") não autorizado. Permitidos: ${allowedRoles.join(', ')}`);
        showAccessDenied(perfil.role, allowedRoles);
        return null;
    }

    console.log('✅ Auth OK! Role:', perfil.role, '| User:', perfil.nome || perfil.email);
    return perfil;
}

/**
 * Verifica se o usuário tem um role específico (sem redirecionar)
 * @param {string} role - Role para verificar
 * @returns {Promise<boolean>}
 */
export async function hasRole(role) {
    const supabase = getSupabase();
    if (!supabase) return false;

    // Usar RPC que é mais confiável
    const rpcRole = await getRoleViaRPC(supabase);
    if (rpcRole) return rpcRole === role;

    const perfil = await getUserProfile();
    return perfil?.role === role;
}

/**
 * Verifica se o usuário é admin (inclui 'dono')
 * @returns {Promise<boolean>}
 */
export async function isAdmin() {
    const perfil = await getUserProfile();
    return isAdminRole(perfil?.role);
}

/**
 * Faz logout e redireciona para login
 */
export async function logout() {
    const supabase = getSupabase();
    if (supabase) {
        try {
            await supabase.auth.signOut({ scope: 'global' });
        } catch (e) { /* ignora */ }
    }
    window.location.replace('login.html?logout=1');
}

/**
 * Mostra tela de acesso negado
 */
function showAccessDenied(currentRole, allowedRoles) {
    const roleLabels = {
        admin: 'Administrador',
        dono: 'Dono do Negócio',
        afiliado: 'Afiliado'
    };

    document.body.innerHTML = `
        <div style="
            min-height: 100vh; 
            background: #0F0F0F; 
            display: flex; 
            align-items: center; 
            justify-content: center;
            font-family: 'Work Sans', sans-serif;
            padding: 20px;
        ">
            <div style="
                max-width: 400px;
                width: 100%;
                background: #1a2f2f;
                border-radius: 20px;
                padding: 40px;
                text-align: center;
                border: 1px solid rgba(255,255,255,0.05);
            ">
                <div style="
                    width: 72px; height: 72px;
                    border-radius: 50%;
                    background: rgba(255, 77, 77, 0.1);
                    display: flex; align-items: center; justify-content: center;
                    margin: 0 auto 20px;
                ">
                    <span class="material-icons-round" style="font-size: 36px; color: #ff4d4d;">lock</span>
                </div>
                <h2 style="color: white; font-size: 20px; font-weight: 700; margin-bottom: 8px;">Acesso Negado</h2>
                <p style="color: #9ca3af; font-size: 14px; line-height: 1.6; margin-bottom: 24px;">
                    Seu perfil <strong style="color: #13ecec;">${roleLabels[currentRole] || currentRole}</strong> 
                    não tem permissão para acessar esta página.
                </p>
                <div style="display: flex; gap: 12px; flex-direction: column;">
                    <button onclick="window.history.back()" style="
                        background: #13ecec; color: #0F0F0F; border: none;
                        padding: 14px; border-radius: 12px; font-weight: 700;
                        font-size: 14px; cursor: pointer;
                    ">Voltar</button>
                    <button onclick="window.location.href='login.html'" style="
                        background: transparent; color: #ff4d4d; border: 2px solid rgba(255,77,77,0.3);
                        padding: 14px; border-radius: 12px; font-weight: 700;
                        font-size: 14px; cursor: pointer;
                    ">Fazer Login com Outra Conta</button>
                </div>
            </div>
        </div>
    `;
}

export default protectPage;
