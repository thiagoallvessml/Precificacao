-- ============================================================
-- FIX: Criar cupons de afiliado para usuários já cadastrados
-- que ainda não possuem codigo_indicacao
--
-- Como rodar:
-- 1. Acesse: https://supabase.com/dashboard/project/SEU_PROJETO/sql/new
-- 2. Cole este SQL e clique em "Run"
-- ============================================================

-- Função auxiliar: gera código limpo a partir do nome
-- Exemplo: "João Silva" → "JOAO10"
CREATE OR REPLACE FUNCTION gerar_codigo_afiliado(nome_usuario TEXT, user_uuid UUID)
RETURNS TEXT AS $$
DECLARE
    v_primeiro_nome TEXT;
    v_codigo_base TEXT;
    v_codigo_final TEXT;
    v_sufixo INT := 0;
BEGIN
    -- Pegar primeiro nome e normalizar
    v_primeiro_nome := split_part(trim(nome_usuario), ' ', 1);
    
    -- Remover acentos e caracteres especiais, uppercase
    v_codigo_base := upper(
        regexp_replace(
            translate(
                v_primeiro_nome,
                'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAaEEEEIIIIOOOOOUUUUC'
            ),
            '[^A-Z0-9]', '', 'g'
        )
    ) || '10';

    -- Se código muito curto, usar parte do UUID
    IF length(v_codigo_base) < 4 THEN
        v_codigo_base := upper(left(replace(user_uuid::text, '-', ''), 6)) || '10';
    END IF;

    -- Verificar unicidade e adicionar sufixo se necessário
    v_codigo_final := v_codigo_base;
    WHILE EXISTS (
        SELECT 1 FROM cupons_afiliado ca WHERE ca.codigo = v_codigo_final
    ) LOOP
        v_sufixo := v_sufixo + floor(random() * 90 + 10)::int;
        v_codigo_final := v_codigo_base || v_sufixo::text;
    END LOOP;

    RETURN v_codigo_final;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- Criar cupons para usuários que ainda não têm codigo_indicacao
-- ============================================================
DO $$
DECLARE
    rec RECORD;
    v_codigo TEXT;
    v_nome_base TEXT;
BEGIN
    FOR rec IN
        SELECT id, nome, email
        FROM perfis_usuarios
        WHERE codigo_indicacao IS NULL OR codigo_indicacao = ''
    LOOP
        -- Usar nome ou parte do email como base
        v_nome_base := COALESCE(
            NULLIF(trim(rec.nome), ''),
            split_part(rec.email, '@', 1)
        );
        
        -- Gerar código único
        v_codigo := gerar_codigo_afiliado(v_nome_base, rec.id);

        -- Inserir cupom na tabela de afiliados
        INSERT INTO cupons_afiliado (
            codigo,
            desconto_percentual,
            comissao_percentual,
            ativo,
            user_id
        ) VALUES (
            v_codigo,
            10,   -- 10% de desconto para o comprador
            10,   -- 10% de comissão para o afiliado
            true,
            rec.id
        )
        ON CONFLICT (codigo) DO NOTHING;

        -- Salvar o codigo_indicacao no perfil do usuário
        UPDATE perfis_usuarios
        SET codigo_indicacao = v_codigo
        WHERE id = rec.id;

        RAISE NOTICE 'Afiliado criado: % → %', rec.email, v_codigo;
    END LOOP;
END;
$$;


-- ============================================================
-- Verificar resultado
-- ============================================================
SELECT
    p.email,
    p.nome,
    p.codigo_indicacao,
    c.desconto_percentual,
    c.comissao_percentual,
    c.ativo
FROM perfis_usuarios p
LEFT JOIN cupons_afiliado c ON c.user_id = p.id
ORDER BY p.created_at DESC
LIMIT 50;


-- Limpar função auxiliar (opcional)
-- DROP FUNCTION IF EXISTS gerar_codigo_afiliado(TEXT, UUID);
