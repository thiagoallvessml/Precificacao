import { getSupabase } from './supabase-client.js';

/**
 * Funções utilitárias para interagir com o Supabase
 */

// ========== AUTENTICAÇÃO ==========

/**
 * Faz login com email e senha
 * @param {string} email 
 * @param {string} password 
 * @returns {Promise<object>} Dados do usuário ou erro
 */
export async function signIn(email, password) {
    const supabase = getSupabase();
    if (!supabase) return { error: 'Supabase não configurado' };

    const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
    });

    if (error) {
        console.error('Erro ao fazer login:', error.message);
        return { error };
    }

    console.log('✅ Login realizado com sucesso!');
    return { data };
}

/**
 * Faz cadastro com email e senha
 * @param {string} email 
 * @param {string} password 
 * @returns {Promise<object>} Dados do usuário ou erro
 */
export async function signUp(email, password) {
    const supabase = getSupabase();
    if (!supabase) return { error: 'Supabase não configurado' };

    const { data, error } = await supabase.auth.signUp({
        email,
        password
    });

    if (error) {
        console.error('Erro ao criar conta:', error.message);
        return { error };
    }

    console.log('✅ Conta criada com sucesso!');
    return { data };
}

/**
 * Faz logout
 * @returns {Promise<object>} Sucesso ou erro
 */
export async function signOut() {
    const supabase = getSupabase();
    if (!supabase) return { error: 'Supabase não configurado' };

    const { error } = await supabase.auth.signOut();

    if (error) {
        console.error('Erro ao fazer logout:', error.message);
        return { error };
    }

    console.log('✅ Logout realizado com sucesso!');
    return { success: true };
}

/**
 * Retorna o usuário atual
 * @returns {Promise<object>} Usuário ou null
 */
export async function getCurrentUser() {
    const supabase = getSupabase();
    if (!supabase) return null;

    const { data: { user } } = await supabase.auth.getUser();
    return user;
}

// ========== OPERAÇÕES NO BANCO DE DADOS ==========

/**
 * Busca todos os registros de uma tabela
 * @param {string} tableName Nome da tabela
 * @returns {Promise<object>} Dados ou erro
 */
export async function getAllRecords(tableName) {
    const supabase = getSupabase();
    if (!supabase) return { error: 'Supabase não configurado' };

    const { data, error } = await supabase
        .from(tableName)
        .select('*');

    if (error) {
        console.error(`Erro ao buscar registros de ${tableName}:`, error.message);
        return { error };
    }

    return { data };
}

/**
 * Busca um registro por ID
 * @param {string} tableName Nome da tabela
 * @param {string|number} id ID do registro
 * @returns {Promise<object>} Dados ou erro
 */
export async function getRecordById(tableName, id) {
    const supabase = getSupabase();
    if (!supabase) return { error: 'Supabase não configurado' };

    const { data, error } = await supabase
        .from(tableName)
        .select('*')
        .eq('id', id)
        .single();

    if (error) {
        console.error(`Erro ao buscar registro ${id} de ${tableName}:`, error.message);
        return { error };
    }

    return { data };
}

/**
 * Insere um novo registro
 * Automaticamente adiciona user_id do usuário logado
 * @param {string} tableName Nome da tabela
 * @param {object} record Objeto com os dados do registro
 * @returns {Promise<object>} Dados inseridos ou erro
 */
export async function insertRecord(tableName, record) {
    const supabase = getSupabase();
    if (!supabase) return { error: 'Supabase não configurado' };

    // Injetar user_id automaticamente se não foi fornecido
    if (!record.user_id) {
        try {
            const { data: { session } } = await supabase.auth.getSession();
            if (session?.user?.id) {
                record.user_id = session.user.id;
            }
        } catch (e) {
            console.warn('Não foi possível obter user_id:', e);
        }
    }

    const { data, error } = await supabase
        .from(tableName)
        .insert([record])
        .select();

    if (error) {
        console.error(`Erro ao inserir registro em ${tableName}:`, error.message);
        return { error };
    }

    console.log(`✅ Registro inserido em ${tableName}`);
    return { data };
}

/**
 * Atualiza um registro existente
 * @param {string} tableName Nome da tabela
 * @param {string|number} id ID do registro
 * @param {object} updates Objeto com os campos a atualizar
 * @returns {Promise<object>} Dados atualizados ou erro
 */
export async function updateRecord(tableName, id, updates) {
    const supabase = getSupabase();
    if (!supabase) return { error: 'Supabase não configurado' };

    const { data, error } = await supabase
        .from(tableName)
        .update(updates)
        .eq('id', id)
        .select();

    if (error) {
        console.error(`Erro ao atualizar registro ${id} em ${tableName}:`, error.message);
        return { error };
    }

    console.log(`✅ Registro atualizado em ${tableName}`);
    return { data };
}

/**
 * Deleta um registro
 * @param {string} tableName Nome da tabela
 * @param {string|number} id ID do registro
 * @returns {Promise<object>} Sucesso ou erro
 */
export async function deleteRecord(tableName, id) {
    const supabase = getSupabase();
    if (!supabase) return { error: 'Supabase não configurado' };

    const { error } = await supabase
        .from(tableName)
        .delete()
        .eq('id', id);

    if (error) {
        console.error(`Erro ao deletar registro ${id} de ${tableName}:`, error.message);
        return { error };
    }

    console.log(`✅ Registro deletado de ${tableName}`);
    return { success: true };
}

/**
 * Busca registros com filtros
 * @param {string} tableName Nome da tabela
 * @param {object} filters Objeto com os filtros (campo: valor)
 * @returns {Promise<object>} Dados ou erro
 */
export async function getRecordsWhere(tableName, filters) {
    const supabase = getSupabase();
    if (!supabase) return { error: 'Supabase não configurado' };

    let query = supabase.from(tableName).select('*');

    // Aplica cada filtro
    Object.entries(filters).forEach(([key, value]) => {
        query = query.eq(key, value);
    });

    const { data, error } = await query;

    if (error) {
        console.error(`Erro ao buscar registros de ${tableName} com filtros:`, error.message);
        return { error };
    }

    return { data };
}

// ========== STORAGE (ARQUIVOS) ==========

/**
 * Faz upload de um arquivo
 * @param {string} bucketName Nome do bucket
 * @param {string} filePath Caminho do arquivo no storage
 * @param {File} file Arquivo a ser enviado
 * @returns {Promise<object>} Dados do upload ou erro
 */
export async function uploadFile(bucketName, filePath, file) {
    const supabase = getSupabase();
    if (!supabase) return { error: 'Supabase não configurado' };

    const { data, error } = await supabase.storage
        .from(bucketName)
        .upload(filePath, file);

    if (error) {
        console.error('Erro ao fazer upload:', error.message);
        return { error };
    }

    console.log('✅ Arquivo enviado com sucesso!');
    return { data };
}

/**
 * Obtém URL pública de um arquivo
 * @param {string} bucketName Nome do bucket
 * @param {string} filePath Caminho do arquivo no storage
 * @returns {string} URL pública do arquivo
 */
export function getPublicUrl(bucketName, filePath) {
    const supabase = getSupabase();
    if (!supabase) return null;

    const { data } = supabase.storage
        .from(bucketName)
        .getPublicUrl(filePath);

    return data.publicUrl;
}

/**
 * Deleta um arquivo
 * @param {string} bucketName Nome do bucket
 * @param {string} filePath Caminho do arquivo no storage
 * @returns {Promise<object>} Sucesso ou erro
 */
export async function deleteFile(bucketName, filePath) {
    const supabase = getSupabase();
    if (!supabase) return { error: 'Supabase não configurado' };

    const { error } = await supabase.storage
        .from(bucketName)
        .remove([filePath]);

    if (error) {
        console.error('Erro ao deletar arquivo:', error.message);
        return { error };
    }

    console.log('✅ Arquivo deletado com sucesso!');
    return { success: true };
}
