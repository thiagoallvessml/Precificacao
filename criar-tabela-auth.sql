-- ============================================================
-- SISTEMA DE AUTENTICAÇÃO COM ROLES
-- Execute este script no Supabase SQL Editor
-- ============================================================

-- 1. Tabela de perfis de usuários (ligada ao auth.users do Supabase)
CREATE TABLE IF NOT EXISTS perfis_usuarios (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nome TEXT NOT NULL DEFAULT '',
    email TEXT NOT NULL DEFAULT '',
    telefone TEXT DEFAULT '',
    role TEXT NOT NULL DEFAULT 'dono' CHECK (role IN ('admin', 'dono', 'afiliado')),
    nome_negocio TEXT DEFAULT '',
    avatar_url TEXT DEFAULT '',
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Índices
CREATE INDEX IF NOT EXISTS idx_perfis_usuarios_role ON perfis_usuarios(role);
CREATE INDEX IF NOT EXISTS idx_perfis_usuarios_email ON perfis_usuarios(email);
CREATE INDEX IF NOT EXISTS idx_perfis_usuarios_ativo ON perfis_usuarios(ativo);

-- 3. Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_perfis_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_perfis ON perfis_usuarios;
CREATE TRIGGER trigger_update_perfis
    BEFORE UPDATE ON perfis_usuarios
    FOR EACH ROW
    EXECUTE FUNCTION update_perfis_updated_at();

-- 4. Função para criar perfil automaticamente no cadastro
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.perfis_usuarios (id, nome, email, role, telefone, nome_negocio)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'nome', NEW.raw_user_meta_data->>'full_name', ''),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'role', 'dono'),
        COALESCE(NEW.raw_user_meta_data->>'telefone', ''),
        COALESCE(NEW.raw_user_meta_data->>'nome_negocio', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Trigger: quando um novo user se cadastrar, cria o perfil automaticamente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 6. Row Level Security (RLS)
ALTER TABLE perfis_usuarios ENABLE ROW LEVEL SECURITY;

-- Política: Usuário pode ver seu próprio perfil
DROP POLICY IF EXISTS "Usuarios podem ver proprio perfil" ON perfis_usuarios;
CREATE POLICY "Usuarios podem ver proprio perfil"
    ON perfis_usuarios
    FOR SELECT
    USING (auth.uid() = id);

-- Política: Usuário pode editar seu próprio perfil
DROP POLICY IF EXISTS "Usuarios podem editar proprio perfil" ON perfis_usuarios;
CREATE POLICY "Usuarios podem editar proprio perfil"
    ON perfis_usuarios
    FOR UPDATE
    USING (auth.uid() = id);

-- Política: Admin pode ver todos os perfis
DROP POLICY IF EXISTS "Admin pode ver todos os perfis" ON perfis_usuarios;
CREATE POLICY "Admin pode ver todos os perfis"
    ON perfis_usuarios
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM perfis_usuarios
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Política: Admin pode editar todos os perfis
DROP POLICY IF EXISTS "Admin pode editar todos os perfis" ON perfis_usuarios;
CREATE POLICY "Admin pode editar todos os perfis"
    ON perfis_usuarios
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM perfis_usuarios
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Política: Permitir insert via trigger (service_role)
DROP POLICY IF EXISTS "Service role pode inserir perfis" ON perfis_usuarios;
CREATE POLICY "Service role pode inserir perfis"
    ON perfis_usuarios
    FOR INSERT
    WITH CHECK (true);

-- ============================================================
-- FUNÇÕES AUXILIARES
-- ============================================================

-- Função RPC para obter o role do usuário logado
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
BEGIN
    RETURN (
        SELECT role FROM public.perfis_usuarios
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função RPC para verificar se é admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        SELECT role = 'admin' FROM public.perfis_usuarios
        WHERE id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- DADOS INICIAIS (Opcional)
-- Descomente e altere o email para criar um admin
-- ============================================================

-- Para promover um usuário existente a admin:
-- UPDATE perfis_usuarios SET role = 'admin' WHERE email = 'seu_email@exemplo.com';

SELECT '✅ Tabela perfis_usuarios criada com sucesso!' AS resultado;
SELECT '✅ Trigger on_auth_user_created configurado!' AS resultado;
SELECT '✅ RLS configurado com sucesso!' AS resultado;
