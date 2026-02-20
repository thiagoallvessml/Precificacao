-- ============================================================
-- CORRIGIR TRIGGER: incluir telefone e nome_negocio no cadastro
-- Execute este script no Supabase SQL Editor
-- ============================================================

-- Recriar a função para salvar TODOS os dados do cadastro
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

SELECT '✅ Trigger handle_new_user atualizado com telefone e nome_negocio!' AS resultado;
