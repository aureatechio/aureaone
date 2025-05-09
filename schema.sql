

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "documentsmeta2";


ALTER SCHEMA "documentsmeta2" OWNER TO "postgres";


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "vector" WITH SCHEMA "public";






CREATE TYPE "public"."osCategoria" AS ENUM (
    'Cabeca',
    'CabecaCelebridade',
    'Assinatura',
    'AssinaturaCelebridade',
    'BackgroundOferta',
    'Trilha',
    'Selo',
    'Celebridades',
    'audioAssinaturaLockoff',
    'Paradinha',
    'ParadinhaCelebridade',
    'Chamada',
    'audioChamadaLockoff',
    'png'
);


ALTER TYPE "public"."osCategoria" OWNER TO "postgres";


CREATE TYPE "public"."osConteudo" AS ENUM (
    'Feed',
    'Reels',
    'Storys',
    'Carrossel',
    'Video',
    'Imagem'
);


ALTER TYPE "public"."osConteudo" OWNER TO "postgres";


COMMENT ON TYPE "public"."osConteudo" IS 'Tipo de conteúdo do post';



CREATE TYPE "public"."osFieldTypeStandard" AS ENUM (
    'Text',
    'Currency',
    'Date'
);


ALTER TYPE "public"."osFieldTypeStandard" OWNER TO "postgres";


CREATE TYPE "public"."osFormatos" AS ENUM (
    '16x9',
    '9x16',
    '1x1',
    '4x5',
    'Null'
);


ALTER TYPE "public"."osFormatos" OWNER TO "postgres";


CREATE TYPE "public"."osMaterial" AS ENUM (
    'Filme 15s',
    'Filme 30s',
    'Null'
);


ALTER TYPE "public"."osMaterial" OWNER TO "postgres";


CREATE TYPE "public"."osPlataformas" AS ENUM (
    'Facebook',
    'Instagram',
    'Tiktok'
);


ALTER TYPE "public"."osPlataformas" OWNER TO "postgres";


CREATE TYPE "public"."osStatus" AS ENUM (
    'Ativo',
    'Inativo'
);


ALTER TYPE "public"."osStatus" OWNER TO "postgres";


CREATE TYPE "public"."osStatusRender" AS ENUM (
    'Renderizando',
    'Finalizado',
    'Erro'
);


ALTER TYPE "public"."osStatusRender" OWNER TO "postgres";


CREATE TYPE "public"."osTrafficType" AS ENUM (
    'Organico',
    'Pago'
);


ALTER TYPE "public"."osTrafficType" OWNER TO "postgres";


COMMENT ON TYPE "public"."osTrafficType" IS 'Tipo de tráfego';



CREATE TYPE "public"."osTypeField" AS ENUM (
    'cta',
    'oferta1ProdutoText',
    'oferta1ProdutoImg',
    'oferta1ProdutoAudio',
    'oferta1PrecoReais',
    'oferta1PrecoCentavos',
    'oferta1AudioPreco',
    'oferta1UnidadeMedida',
    'oferta2ProdutoText',
    'oferta2ProdutoImg',
    'oferta2ProdutoAudio',
    'oferta2PrecoReais',
    'oferta2PrecoCentavos',
    'oferta2AudioPreco',
    'oferta2UnidadeMedida',
    'oferta3ProdutoText',
    'oferta3ProdutoImg',
    'oferta3ProdutoAudio',
    'oferta3PrecoReais',
    'oferta3PrecoCentavos',
    'oferta3AudioPreco',
    'oferta3UnidadeMedida',
    'oferta4ProdutoText',
    'oferta4ProdutoImg',
    'oferta4ProdutoAudio',
    'oferta4PrecoReais',
    'oferta4PrecoCentavos',
    'oferta4AudioPreco',
    'oferta4UnidadeMedida',
    'oferta5ProdutoText',
    'oferta5ProdutoImg',
    'oferta5ProdutoAudio',
    'oferta5PrecoReais',
    'oferta5PrecoCentavos',
    'oferta5AudioPreco',
    'oferta5UnidadeMedida',
    'Selo',
    'Celebridade',
    'CTA',
    'Header'
);


ALTER TYPE "public"."osTypeField" OWNER TO "postgres";


CREATE TYPE "public"."osTypeMidia" AS ENUM (
    'Video',
    'Estatica',
    'Radio'
);


ALTER TYPE "public"."osTypeMidia" OWNER TO "postgres";


CREATE TYPE "public"."osTypeNotification" AS ENUM (
    'PreviewMidia',
    'ErrorRender',
    'NewTemplate'
);


ALTER TYPE "public"."osTypeNotification" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "documentsmeta2"."match_meta2_documents"("query_embedding" "public"."vector", "match_count" integer DEFAULT NULL::integer, "filter" "jsonb" DEFAULT '{}'::"jsonb") RETURNS TABLE("id" bigint, "content" "text", "metadata" "jsonb", "similarity" double precision)
    LANGUAGE "plpgsql"
    AS $$
#variable_conflict use_column
begin
  return query
  select
    d.id,
    d.content,
    d.metadata,
    1 - (d.embedding <=> query_embedding) as similarity
  from documentsmeta2.documents d
  where d.metadata @> filter
  order by d.embedding <=> query_embedding
  limit match_count;
end;
$$;


ALTER FUNCTION "documentsmeta2"."match_meta2_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."atualizarIndex"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$BEGIN
    CASE NEW."osFormatos"::TEXT
        WHEN '16x9' THEN NEW."indexFile" := 1;
        WHEN '9x16' THEN NEW."indexFile" := 2;
        WHEN '1x1' THEN NEW."indexFile" := 3;
    END CASE;

    RETURN NEW;
END;$$;


ALTER FUNCTION "public"."atualizarIndex"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."execute_sql"("query" "text", "params" "text"[]) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_result JSONB;
BEGIN
  EXECUTE query INTO v_result USING params[1], params[2];
  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Erro no SQL: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."execute_sql"("query" "text", "params" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_column_list"() RETURNS TABLE("column_name" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  return query
  select column_name
  from information_schema.columns
  where table_name = 'Template'
    and table_schema = 'public';
end;
$$;


ALTER FUNCTION "public"."get_column_list"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_columns"() RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  result text;
begin
  select string_agg(column_name, ', ')
  into result
  from information_schema.columns
  where table_name = 'Template'
    and table_schema = 'public';

  return result;
end;
$$;


ALTER FUNCTION "public"."get_columns"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_columns"("table_name_input" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
declare
  result text;
begin
  select string_agg(column_name, ', ')
  into result
  from information_schema.columns
  where table_name = "PreviewMidia"
    and table_schema = 'public';

  return result;
end;
$$;


ALTER FUNCTION "public"."get_columns"("table_name_input" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."inserir_midia_direta"("p_name_file" "text", "p_url_file" "text", "p_os_categoria" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_id UUID;
  v_result JSONB;
BEGIN
  -- Inserir diretamente via SQL para contornar triggers e validações
  INSERT INTO public."MMidias" (
    "nameFile",
    "urlFile",
    "indexFile",
    "active",
    "createdBy",
    "createdDate",
    "osCategoria"
  )
  VALUES (
    p_name_file,
    p_url_file,
    0,
    TRUE,
    'webhook',
    NOW(),
    p_os_categoria::public."osCategoria"
  )
  RETURNING id INTO v_id;
  
  -- Retornar o registro inserido
  SELECT json_build_object(
    'id', m.id,
    'nameFile', m."nameFile",
    'urlFile', m."urlFile",
    'osCategoria', m."osCategoria"
  ) INTO v_result
  FROM public."MMidias" m
  WHERE id = v_id;
  
  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Erro na inserção direta: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."inserir_midia_direta"("p_name_file" "text", "p_url_file" "text", "p_os_categoria" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."match_documents"("query_embedding" "public"."vector", "match_count" integer DEFAULT NULL::integer, "filter" "jsonb" DEFAULT '{}'::"jsonb") RETURNS TABLE("id" bigint, "content" "text", "metadata" "jsonb", "similarity" double precision)
    LANGUAGE "plpgsql"
    AS $$
#variable_conflict use_column
begin
  return query
  select
    id,
    content,
    metadata,
    1 - (documentsAureaAI.embedding <=> query_embedding) as similarity
  from documentsAureaAI
  where metadata @> filter
  order by documentsAureaAI.embedding <=> query_embedding
  limit match_count;
end;
$$;


ALTER FUNCTION "public"."match_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."match_meta_documents"("query_embedding" "public"."vector", "match_count" integer DEFAULT NULL::integer, "filter" "jsonb" DEFAULT '{}'::"jsonb") RETURNS TABLE("id" bigint, "content" "text", "metadata" "jsonb", "similarity" double precision)
    LANGUAGE "plpgsql"
    AS $$
#variable_conflict use_column
begin
  return query
  select
    id,
    content,
    metadata,
    1 - (documentsMeta.embedding <=> query_embedding) as similarity
  from documentsMeta
  where metadata @> filter
  order by documentsMeta.embedding <=> query_embedding
  limit match_count;
end;
$$;


ALTER FUNCTION "public"."match_meta_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."match_tiktok_documents"("query_embedding" "public"."vector", "match_count" integer DEFAULT NULL::integer, "filter" "jsonb" DEFAULT '{}'::"jsonb") RETURNS TABLE("id" bigint, "content" "text", "metadata" "jsonb", "similarity" double precision)
    LANGUAGE "plpgsql"
    AS $$
#variable_conflict use_column
begin
  return query
  select
    id,
    content,
    metadata,
    1 - (documentsTiktok.embedding <=> query_embedding) as similarity
  from documentsTiktok
  where metadata @> filter
  order by documentsTiktok.embedding <=> query_embedding
  limit match_count;
end;
$$;


ALTER FUNCTION "public"."match_tiktok_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_index_file"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    CASE NEW.osFormatos
        WHEN '16x9' THEN NEW.indexFile := 1;
        WHEN '9x16' THEN NEW.indexFile := 2;
        WHEN '1x1' THEN NEW.indexFile := 3;
        ELSE NEW.indexFile := NULL; -- Se houver outros formatos, pode ser tratado aqui
    END CASE;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_index_file"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "documentsmeta2"."documents" (
    "id" bigint NOT NULL,
    "content" "text",
    "metadata" "jsonb",
    "embedding" "public"."vector"(1536)
);


ALTER TABLE "documentsmeta2"."documents" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "documentsmeta2"."documents_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "documentsmeta2"."documents_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "documentsmeta2"."documents_id_seq" OWNED BY "documentsmeta2"."documents"."id";



CREATE TABLE IF NOT EXISTS "public"."Ads" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "idAds" "text",
    "contaAdsId" "uuid",
    "templateText" "text",
    "grupoAnuncioId" "uuid",
    "name" "text",
    "notaAds" integer,
    "tipoAnuncioId" "uuid",
    "ultimoInsigthCpc" numeric,
    "ultimoInsigthClicks" numeric,
    "ultimoInsigthCpm" numeric,
    "ultimoInsigthAlcance" numeric,
    "ultimoInsigthCtr" numeric,
    "ultimoInsigthImpressao" numeric,
    "ultimoInsigthTempoVisualizacao" numeric,
    "ultimoInsigthValorGasto" numeric,
    "campanhaId" "uuid",
    "contaPlataforma" "uuid",
    "urlMidia" "text"
);


ALTER TABLE "public"."Ads" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."AjusteCampanha" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "assinaturaSpeed" numeric,
    "bebidaSpeed" numeric,
    "cabecaSpeed" numeric,
    "templateId" "uuid",
    "txtLegalSpeed" numeric,
    "modifiedDate" "date" DEFAULT CURRENT_DATE,
    "createdDate" "date" DEFAULT CURRENT_DATE
);


ALTER TABLE "public"."AjusteCampanha" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."BrandKit" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "cor_primaria" "text",
    "cor_secundaria" "text",
    "cor_terciaria" "text",
    "logo" "text",
    "fonte" "text",
    "empresa" "uuid"
);


ALTER TABLE "public"."BrandKit" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Campanhas" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "idCampanha" "text",
    "ContaAds" "uuid",
    "nomeCampanha" "text",
    "inicioCampanha" "date",
    "terminoCampanha" "date",
    "plataforma" "uuid",
    "tipoCampanha" "uuid"
);


ALTER TABLE "public"."Campanhas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."CamposAds" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "tipoAnuncioId" "uuid",
    "parametroAPI" "text",
    "descricaoCampo" "text"
);


ALTER TABLE "public"."CamposAds" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."CamposCampanha" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "descricaoCampo" "text",
    "parametroAPI" "text",
    "plataformaId" "uuid",
    "valorPadrao" "text",
    "tipoCampo" "text",
    "usuarioPreencher" boolean
);


ALTER TABLE "public"."CamposCampanha" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."CamposCampanhaValores" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "valorCampo" "text",
    "parametroAPI" "text",
    "descricaoCampo" "text",
    "usuarioPreencher" boolean,
    "campanha" "uuid",
    "valorpadrao" "text",
    "ordem" numeric,
    "typeField" "text"
);


ALTER TABLE "public"."CamposCampanhaValores" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."CamposGrupoAds" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "parametroAPI" "text",
    "descricaoCampo" "text",
    "plataforma" "uuid",
    "valorPadrao" "text",
    "usuarioPreencher" boolean,
    "tipoDado" "text",
    "sequencia" "text"
);


ALTER TABLE "public"."CamposGrupoAds" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."CamposTemplateSetup" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "fieldName" "text",
    "templateId" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "visivelUsuario" boolean,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "fieldCreatomate" "text",
    "indexOferta" "text"
);


ALTER TABLE "public"."CamposTemplateSetup" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Celebridade" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text",
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "pro" boolean DEFAULT false,
    "urlThumb" "text",
    "indexID" numeric,
    "free" boolean DEFAULT false,
    "ativo" boolean DEFAULT false,
    "filtreCelebridade" "text",
    "urlCelebridade" "text"
);


ALTER TABLE "public"."Celebridade" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ContasAds" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "idContaAds" "text",
    "nomeContaAds" "text",
    "contaBusinessId" "uuid",
    "plataforma" "uuid",
    "plataformaId" "text",
    "identifyId" "text"
);


ALTER TABLE "public"."ContasAds" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ContasBusiness" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "contasAdsId" "uuid",
    "name" "text",
    "paginasAnuncioId" "uuid",
    "businessID" "text"
);


ALTER TABLE "public"."ContasBusiness" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Contas_Plataforma" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "accessToken" "text",
    "emailConta" "text",
    "idConta" "text",
    "active" boolean DEFAULT true,
    "name" "text",
    "plataforma" "uuid",
    "plataformaId" "text",
    "refreshToken" "text",
    "expire_token" timestamp with time zone,
    "identifyId" "text"
);


ALTER TABLE "public"."Contas_Plataforma" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Empresas" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "name" "text" NOT NULL,
    "tradeName" "text",
    "endereçod" "uuid",
    "cnpj" "text",
    "setorAtuacao" "text",
    "telefone" "text",
    "email" "text",
    "logo" "text"
);


ALTER TABLE "public"."Empresas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Enderecos" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "street" "text",
    "number" "text",
    "cep" "text",
    "district" "text",
    "city" "text"
);


ALTER TABLE "public"."Enderecos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."GruposAds" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "idGrupoAds" "text",
    "contaAdsId" "uuid",
    "tipoAnuncioId" "uuid",
    "campanhaId" "uuid",
    "plataforma" "uuid",
    "generoAnuncio" "text",
    "idadeMax" "text",
    "idadeMin" "text",
    "creator" "text",
    "nomeGrupo" "text"
);


ALTER TABLE "public"."GruposAds" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Instagram" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "idAnuncio" "text",
    "nomeInstagran" "text",
    "idIdentificacao" "text",
    "fotoPerfil" "text",
    "nomeUsuario" "text",
    "access_token" "text",
    "status" "public"."osStatus"
);


ALTER TABLE "public"."Instagram" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."LocalizacaoAnuncios" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "descricao" "text",
    "chaveLocal" "text",
    "grupoAnuncio" "uuid",
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "type" "text",
    "raio" numeric
);


ALTER TABLE "public"."LocalizacaoAnuncios" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."MCategoria" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" character varying(255)
);


ALTER TABLE "public"."MCategoria" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."MMidias" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "nameFile" character varying(255),
    "urlFile" character varying,
    "indexFile" integer,
    "active" boolean DEFAULT true,
    "thumbUrl" "text",
    "templateId" "uuid",
    "templateFormatoId" "uuid",
    "createdBy" character varying,
    "createdDate" timestamp without time zone DEFAULT "now"(),
    "categoryId" "uuid",
    "osCategoria" "public"."osCategoria",
    "osMaterial" "public"."osMaterial",
    "osFormatos" "public"."osFormatos",
    "fieldCreatomate" "text",
    "ativo" boolean,
    "osTypeMidiaTemplate" "public"."osTypeMidia",
    "filterCelebridade" "text"
);


ALTER TABLE "public"."MMidias" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Ofertas" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "title" character varying(255),
    "description" "text",
    "discount" numeric(5,2),
    "productId" "uuid",
    "createdAt" timestamp without time zone DEFAULT "now"(),
    "updatedAt" timestamp without time zone DEFAULT "now"(),
    "price" "text",
    "lista" "uuid",
    "position" smallint
);


ALTER TABLE "public"."Ofertas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."PaginasAnuncio" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "idPagina" "text",
    "nomePagina" "text",
    "contaBusinessPaginaId" "uuid",
    "instagranId" "uuid",
    "pictureUrl" "text",
    "accessToken" "text",
    "status" "public"."osStatus"
);


ALTER TABLE "public"."PaginasAnuncio" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Plataformas" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "platform" "text",
    "active" boolean DEFAULT true,
    "description" "text",
    "logoImage" "text",
    "apiVersion" "text",
    "idPlataforma" "text"
);


ALTER TABLE "public"."Plataformas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."PreConfiguracaoPost" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "empresa" "uuid",
    "impacto" "text",
    "marcacoes" "text",
    "hashtags" "text"
);


ALTER TABLE "public"."PreConfiguracaoPost" OWNER TO "postgres";


COMMENT ON TABLE "public"."PreConfiguracaoPost" IS 'Tabela que mostra os registros de pré configuração para os posts';



CREATE TABLE IF NOT EXISTS "public"."PreviewMidia" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "listMCabeca" "uuid"[],
    "listMBackgroundOfertas" "uuid"[],
    "listMAssinatura" "uuid"[],
    "listMBackgroundOferta" "uuid"[],
    "listMCelebridades" "uuid"[],
    "listOfertas" "uuid"[],
    "listTypeMidia" "uuid"[],
    "listMaterial" "uuid"[],
    "listRender" "uuid"[],
    "listPraca" "text",
    "geoLocalizacao" "text",
    "osStatusFilme" character varying(50),
    "mSelo" character varying(255),
    "textoLegal" "text",
    "createdBy" character varying,
    "createdDate" timestamp without time zone DEFAULT "now"(),
    "uuid" "uuid",
    "creator" "text",
    "empresa" "uuid",
    "templateId" "uuid",
    "testeMauro" "jsonb",
    "editFinalizada" boolean,
    "filterCeleb" "text",
    "categoriaSelecionada" "text"
);


ALTER TABLE "public"."PreviewMidia" OWNER TO "postgres";


COMMENT ON TABLE "public"."PreviewMidia" IS 'Tabela de pré-visualização de mídias renderizadas para campanhas.';



CREATE TABLE IF NOT EXISTS "public"."Produto" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "precificador" "text" NOT NULL,
    "typeProduct" character varying(50),
    "description" "text",
    "createdAt" timestamp without time zone DEFAULT "now"(),
    "updatedAt" timestamp without time zone DEFAULT "now"(),
    "creator" "uuid",
    "empresa" "uuid",
    "urlImg" "text",
    "skuAurea" "text",
    "urlAudio" "text",
    "ativo" boolean,
    "precoReal" "text",
    "precoCentavo" "text",
    "tempoMillisegundos" "text",
    "categoria" "text",
    "subcategoria" "text",
    "audioPreco" "text",
    "ofertaSemana" boolean DEFAULT false,
    CONSTRAINT "chk_produto_typeProduct" CHECK ((("typeProduct")::"text" = ANY ((ARRAY['carro'::character varying, 'supermecado'::character varying, 'padaria'::character varying])::"text"[])))
);


ALTER TABLE "public"."Produto" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Publico" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "gender" "text",
    "age" "text",
    "geoLocalizacao" "text",
    "empresa" "uuid"
);


ALTER TABLE "public"."Publico" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Render" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "mCabeca" "uuid",
    "mBackgroundOferta" "uuid",
    "mAssinatura" "uuid",
    "mBackgroundEstatica" "uuid",
    "mCelebridade" "uuid",
    "templateId" "uuid",
    "templateId2" "uuid",
    "status" character varying(50),
    "videoUrl" "text",
    "colorText" "text",
    "listOfertas" "uuid",
    "templateFormatoId" "uuid",
    "osTypeMidia" "public"."osTypeMidia",
    "createdAt" timestamp without time zone DEFAULT ("now"() AT TIME ZONE 'America/Sao_Paulo'::"text"),
    "updatedAt" timestamp with time zone,
    "geoLocalizacao" "text",
    "creator" "text",
    "empresa" "uuid",
    "mCabecaUrl" "text",
    "mBackgroundUrl" "text",
    "mAssinaturaUrl" "text",
    "mTrilhaUrl" "text",
    "previewMidiaId" "uuid",
    "thumbnailUrl" "text",
    "osFormatos" "public"."osFormatos",
    "filterCeleb" "text",
    "sateliteTemplateFormatoId" "uuid",
    "idCreatomateTemplate" "text",
    "osStatusRender" "public"."osStatusRender",
    "errorMsg" "text",
    "postAgendado" boolean DEFAULT false,
    "renderNoticado" boolean DEFAULT false,
    "nameRender" "text",
    CONSTRAINT "chk_render_status" CHECK ((("status")::"text" = ANY ((ARRAY['pending'::character varying, 'processing'::character varying, 'completed'::character varying, 'failed'::character varying])::"text"[])))
);


ALTER TABLE "public"."Render" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."SateliteCamposFormPreviewMidia" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "templateId" "uuid",
    "previewMidiaId" "uuid",
    "campoTemplateSetupId" "uuid",
    "valorCampo" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "visivelUsuario" boolean,
    "fieldCreatomate" "text",
    "indexOferta" "text"
);


ALTER TABLE "public"."SateliteCamposFormPreviewMidia" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."SatelitePreviewMidiaTemplate" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "previewMidiaId" "uuid" NOT NULL,
    "templateId" "uuid" NOT NULL,
    "MMidiasId" "uuid" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "osMaterial" "public"."osMaterial",
    "osCategoria" "public"."osCategoria",
    "osTypeMidiaTemplate" "public"."osTypeMidia",
    "osFormatos" "public"."osFormatos",
    "urlFile" "text",
    "fieldCreatomate" "text",
    "templateFormatoId" "uuid",
    "filterCelebridade" "text"
);


ALTER TABLE "public"."SatelitePreviewMidiaTemplate" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."SateliteTemplateFormato" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "previewMidiaId" "uuid" NOT NULL,
    "templateId" "uuid" NOT NULL,
    "templateFormatoSetupId" "uuid" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "idCreatomateTemplate" "text",
    "osFormatos" "public"."osFormatos",
    "osTypeMidia" "public"."osTypeMidia",
    "active" boolean,
    "urlThumb" "text",
    "name" "text",
    "selectClient" boolean DEFAULT true,
    "selectClientFront" boolean DEFAULT false,
    "categoriaSelecionada" "public"."osCategoria"
);


ALTER TABLE "public"."SateliteTemplateFormato" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Template" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "active" boolean DEFAULT true,
    "colorLetras" "text",
    "thumbUrl" "text",
    "optionText" "text",
    "createdDate" timestamp without time zone DEFAULT "now"(),
    "osMaterial" "public"."osMaterial"[],
    "osTypeMidia" "public"."osTypeMidia"[],
    "listMmidias" "uuid"[],
    "collumn" "text"[]
);


ALTER TABLE "public"."Template" OWNER TO "postgres";


COMMENT ON TABLE "public"."Template" IS 'id, active, colorLetras, thumbUrl, optionText, createdDate, osMaterial, osTypeMidia, listMmidias, collumn
';



CREATE TABLE IF NOT EXISTS "public"."TemplateFormatoSetup" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "active" boolean DEFAULT true,
    "tiposCampanha" "uuid",
    "jsonData" "text",
    "osRedeSociais" character varying(50),
    "name" "text",
    "creator" "uuid",
    "osTypeMidia" "public"."osTypeMidia",
    "idCreatomate" "text",
    "osFormato" "public"."osFormatos" DEFAULT '16x9'::"public"."osFormatos",
    "templateId" "uuid" DEFAULT "gen_random_uuid"(),
    "urlThumb" "text",
    "quantidadeOfertas" "text",
    "editaCelebridade" boolean,
    "editarOferta" boolean,
    "previa" "text",
    CONSTRAINT "chk_templateFormato_osRedeSociais" CHECK ((("osRedeSociais")::"text" = ANY ((ARRAY['Facebook'::character varying, 'Instagram'::character varying, 'outro'::character varying])::"text"[])))
);


ALTER TABLE "public"."TemplateFormatoSetup" OWNER TO "postgres";


COMMENT ON COLUMN "public"."TemplateFormatoSetup"."previa" IS 'valor utilizado para mostrar a previa do template no frontend';



CREATE TABLE IF NOT EXISTS "public"."Tiktok" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "accessToken" "text",
    "refreshToken" "text",
    "fotoPerfil" "text",
    "nomeUsuario" "text",
    "status" "public"."osStatus"
);


ALTER TABLE "public"."Tiktok" OWNER TO "postgres";


COMMENT ON TABLE "public"."Tiktok" IS 'Tiktok pages for organic posts';



CREATE TABLE IF NOT EXISTS "public"."TiposAnuncio" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "idTipoAnuncio" numeric,
    "nomeVisualizacao" "text",
    "variacoesTesteAz" integer,
    "plataformaId" "uuid",
    "active" boolean DEFAULT true,
    "description" "text",
    "plataforma" "text",
    "localPublicar" "text",
    "id_integer" integer NOT NULL,
    "capa" "text"
);


ALTER TABLE "public"."TiposAnuncio" OWNER TO "postgres";


COMMENT ON COLUMN "public"."TiposAnuncio"."capa" IS 'Coluna utilizada para puxar a imagem de capa do formato';



CREATE TABLE IF NOT EXISTS "public"."TiposAnuncioCriados" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "tipoAnuncio" "uuid",
    "grupoAds" "uuid",
    "ads" "uuid",
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."TiposAnuncioCriados" OWNER TO "postgres";


ALTER TABLE "public"."TiposAnuncio" ALTER COLUMN "id_integer" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."TiposAnuncio_id_integer_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."TiposCampanha" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "idTipoCampanha" integer,
    "nomeTipoCampanha" "text",
    "parametroAPI" "text",
    "plataformaId" "uuid"
);


ALTER TABLE "public"."TiposCampanha" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."Usuarios" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "name" "text",
    "secondName" "text",
    "companyOriginal" "uuid",
    "plan" "text",
    "cpf" "text",
    "addressId" "uuid"
);


ALTER TABLE "public"."Usuarios" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ValoresCamposAds" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "valorCampo" "text",
    "parametroAPI" "text",
    "ads" "uuid",
    "usuarioPreencher" boolean,
    "ordem" numeric,
    "descricao" "text"
);


ALTER TABLE "public"."ValoresCamposAds" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ValoresCamposGrupoAds" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "createdDate" "date" DEFAULT CURRENT_DATE,
    "valorCampo" "text",
    "parametroAPI" "text",
    "grupoAds" "uuid",
    "descrição" "text",
    "usuarioPrencher" boolean,
    "ordem" numeric,
    "tipoDado" "text",
    "sequencia" "text"
);


ALTER TABLE "public"."ValoresCamposGrupoAds" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chatUsuário" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "criador" "text",
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."chatUsuário" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."documentsaureaai" (
    "id" bigint NOT NULL,
    "content" "text",
    "metadata" "jsonb",
    "embedding" "public"."vector"(1536)
);


ALTER TABLE "public"."documentsaureaai" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."documents_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."documents_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."documents_id_seq" OWNED BY "public"."documentsaureaai"."id";



CREATE TABLE IF NOT EXISTS "public"."interessesAnuncios" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "nomeInteresse" "text",
    "grupoAds" "uuid",
    "idInteresse" "text"
);


ALTER TABLE "public"."interessesAnuncios" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."listasDeOfertas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "nome" "text",
    "status" "text",
    "creator" "text",
    "empresa" "uuid",
    "dataInicio" "date",
    "dataTermino" "date"
);


ALTER TABLE "public"."listasDeOfertas" OWNER TO "postgres";


COMMENT ON TABLE "public"."listasDeOfertas" IS 'Tabela criada para armazenar a lista de ofertas criadas pelos usuários. Esta lista funciona como uma pré seleção de ofertas para gerar as midias';



CREATE TABLE IF NOT EXISTS "public"."logNotificacao" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "previewMidiaId" "uuid" DEFAULT "gen_random_uuid"(),
    "creator" "text",
    "osTypeNotification" "public"."osTypeNotification",
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "visualizado" boolean DEFAULT false
);


ALTER TABLE "public"."logNotificacao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."maudioPrecos" (
    "filterFieldReais" "text",
    "urlAudio" "text",
    "filterFieldCentavos" "text",
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "createdDate" "date",
    "createdBy" "text",
    "precoCompleto" "text",
    "nameFile" "text",
    "ativo" boolean
);


ALTER TABLE "public"."maudioPrecos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."mensagensChat" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "mensagemUsuário" "text",
    "mensagemIA" "text",
    "creador" "text",
    "chat" "uuid"
);


ALTER TABLE "public"."mensagensChat" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."midiasTeste" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "url_midia" "text",
    "thumbnail" "text",
    "formato" "public"."osFormatos",
    "midiaType" "public"."osTypeMidia"
);


ALTER TABLE "public"."midiasTeste" OWNER TO "postgres";


COMMENT ON TABLE "public"."midiasTeste" IS 'Tabela criada para testar posts';



CREATE TABLE IF NOT EXISTS "public"."n8n_chat_histories" (
    "id" integer NOT NULL,
    "session_id" character varying(255) NOT NULL,
    "message" "jsonb" NOT NULL
);


ALTER TABLE "public"."n8n_chat_histories" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."n8n_chat_histories_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."n8n_chat_histories_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."n8n_chat_histories_id_seq" OWNED BY "public"."n8n_chat_histories"."id";



CREATE TABLE IF NOT EXISTS "public"."ofertaPivotada" (
    "indexOferta" "text" NOT NULL,
    "previewMidiaId" "uuid" NOT NULL,
    "audioPreco" "text",
    "audioProduto" "text",
    "imagemProduto" "text",
    "oferta_visible" "text",
    "precoCentavosOferta" "text",
    "precoRealOferta" "text",
    "textoLegalOferta" "text",
    "tituloOferta" "text",
    "finalBebida.visible" "text"
);


ALTER TABLE "public"."ofertaPivotada" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ofertas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "lista" "uuid",
    "produto" "uuid",
    "valor" "text",
    "posicao" smallint
);


ALTER TABLE "public"."ofertas" OWNER TO "postgres";


COMMENT ON TABLE "public"."ofertas" IS 'Tabela auxiliar para agrupar as ofertas pré selecionadas nas listas';



CREATE TABLE IF NOT EXISTS "public"."postagens" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "creator" "text",
    "empresa" "uuid",
    "url_midia" "text",
    "formato" "public"."osFormatos",
    "midia_type" "public"."osTypeMidia",
    "plataforma" "text",
    "thumbnail" "text",
    "programado" boolean,
    "data_postagem" timestamp with time zone DEFAULT "now"(),
    "nome_campanha" "text",
    "traffic_type" "public"."osTrafficType",
    "conteudo" "text",
    "id_social_account" "text",
    "descricao" "text",
    "hashtags" "text",
    "status" "text" DEFAULT 'postado'::"text",
    "id_campanha" "uuid"
);


ALTER TABLE "public"."postagens" OWNER TO "postgres";


COMMENT ON TABLE "public"."postagens" IS 'Registro das postagens organicas';



CREATE OR REPLACE VIEW "public"."viewOfertaAgrupada" AS
 SELECT "SateliteCamposFormPreviewMidia"."indexOferta",
    "json_agg"("json_build_object"('fieldCreatomate', "SateliteCamposFormPreviewMidia"."fieldCreatomate", 'previewMidiaId', "SateliteCamposFormPreviewMidia"."previewMidiaId", 'campoTemplateSetupId', "SateliteCamposFormPreviewMidia"."campoTemplateSetupId")) AS "campos"
   FROM "public"."SateliteCamposFormPreviewMidia"
  WHERE ("SateliteCamposFormPreviewMidia"."indexOferta" IS NOT NULL)
  GROUP BY "SateliteCamposFormPreviewMidia"."indexOferta";


ALTER TABLE "public"."viewOfertaAgrupada" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."viewOfertaEstruturada" AS
 SELECT "SateliteCamposFormPreviewMidia"."indexOferta",
    "max"(("SateliteCamposFormPreviewMidia"."id")::"text") AS "id",
    "max"(("SateliteCamposFormPreviewMidia"."templateId")::"text") AS "templateid",
    "max"(("SateliteCamposFormPreviewMidia"."previewMidiaId")::"text") AS "previewmidiaid",
    "max"(("SateliteCamposFormPreviewMidia"."campoTemplateSetupId")::"text") AS "campotemplatesetupid",
    "max"("SateliteCamposFormPreviewMidia"."valorCampo") AS "valorcampo",
    "max"("SateliteCamposFormPreviewMidia"."created_at") AS "created_at",
    ("max"(("SateliteCamposFormPreviewMidia"."visivelUsuario")::integer))::boolean AS "visivelusuario",
    "max"("SateliteCamposFormPreviewMidia"."fieldCreatomate") AS "fieldcreatomate"
   FROM "public"."SateliteCamposFormPreviewMidia"
  WHERE ("SateliteCamposFormPreviewMidia"."previewMidiaId" IS NOT NULL)
  GROUP BY "SateliteCamposFormPreviewMidia"."indexOferta";


ALTER TABLE "public"."viewOfertaEstruturada" OWNER TO "postgres";


CREATE MATERIALIZED VIEW "public"."viewOfertaPivotada" AS
 WITH "base" AS (
         SELECT "SateliteCamposFormPreviewMidia"."indexOferta",
            "SateliteCamposFormPreviewMidia"."previewMidiaId",
            "SateliteCamposFormPreviewMidia"."fieldCreatomate",
            "SateliteCamposFormPreviewMidia"."valorCampo",
            "substring"("SateliteCamposFormPreviewMidia"."indexOferta", '\d+'::"text") AS "idx"
           FROM "public"."SateliteCamposFormPreviewMidia"
          WHERE (("SateliteCamposFormPreviewMidia"."indexOferta" IS NOT NULL) AND ("SateliteCamposFormPreviewMidia"."indexOferta" <> ''::"text") AND ("SateliteCamposFormPreviewMidia"."previewMidiaId" IS NOT NULL))
        )
 SELECT "base"."indexOferta",
    "base"."previewMidiaId",
    "max"("base"."valorCampo") FILTER (WHERE ("base"."fieldCreatomate" = ('audioPreco'::"text" || "base"."idx"))) AS "audioPreco",
    "max"("base"."valorCampo") FILTER (WHERE ("base"."fieldCreatomate" = ('audioProduto'::"text" || "base"."idx"))) AS "audioProduto",
    "max"("base"."valorCampo") FILTER (WHERE ("base"."fieldCreatomate" = ('imagemOferta'::"text" || "base"."idx"))) AS "imagemOferta",
    "max"("base"."valorCampo") FILTER (WHERE ("base"."fieldCreatomate" = (('oferta'::"text" || "base"."idx") || '.visible'::"text"))) AS "oferta_visible",
    "max"("base"."valorCampo") FILTER (WHERE ("base"."fieldCreatomate" = (('precoOferta'::"text" || "base"."idx") || 'Centavos'::"text"))) AS "precoOfertaCentavos",
    "max"("base"."valorCampo") FILTER (WHERE ("base"."fieldCreatomate" = (('precoOferta'::"text" || "base"."idx") || 'Real'::"text"))) AS "precoOfertaReal",
    "max"("base"."valorCampo") FILTER (WHERE ("base"."fieldCreatomate" = ('textoLegalOferta'::"text" || "base"."idx"))) AS "textoLegalOferta",
    "max"("base"."valorCampo") FILTER (WHERE ("base"."fieldCreatomate" = ('tituloOferta'::"text" || "base"."idx"))) AS "tituloOferta",
    "max"("base"."valorCampo") FILTER (WHERE ("base"."fieldCreatomate" = 'finalBebida.visible'::"text")) AS "finalBebida.visible"
   FROM "base"
  GROUP BY "base"."indexOferta", "base"."previewMidiaId"
  WITH NO DATA;


ALTER TABLE "public"."viewOfertaPivotada" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."viewSocialAccount" AS
 SELECT "Tiktok"."id",
    "Tiktok"."empresa",
    "Tiktok"."creator",
    "Tiktok"."fotoPerfil",
    NULL::"text" AS "idPagina",
    "Tiktok"."nomeUsuario" AS "nomePagina",
    "Tiktok"."accessToken" AS "access_token",
    'Tiktok'::"public"."osPlataformas" AS "plataforma",
    COALESCE("Tiktok"."status", 'Inativo'::"public"."osStatus") AS "status"
   FROM "public"."Tiktok"
UNION ALL
 SELECT "Instagram"."id",
    "Instagram"."empresa",
    "Instagram"."creator",
    "Instagram"."fotoPerfil",
    "Instagram"."idIdentificacao" AS "idPagina",
    "Instagram"."nomeInstagran" AS "nomePagina",
    "Instagram"."access_token",
    'Instagram'::"public"."osPlataformas" AS "plataforma",
    COALESCE("Instagram"."status", 'Inativo'::"public"."osStatus") AS "status"
   FROM "public"."Instagram"
UNION ALL
 SELECT "PaginasAnuncio"."id",
    "PaginasAnuncio"."empresa",
    "PaginasAnuncio"."creator",
    "PaginasAnuncio"."pictureUrl" AS "fotoPerfil",
    "PaginasAnuncio"."idPagina",
    "PaginasAnuncio"."nomePagina",
    "PaginasAnuncio"."accessToken" AS "access_token",
    'Facebook'::"public"."osPlataformas" AS "plataforma",
    COALESCE("PaginasAnuncio"."status", 'Inativo'::"public"."osStatus") AS "status"
   FROM "public"."PaginasAnuncio";


ALTER TABLE "public"."viewSocialAccount" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."view_contas_plataforma" AS
 SELECT "cp"."id" AS "id_conta",
    "cp"."creator",
    "emp"."id" AS "empresa_id",
    "emp"."name" AS "empresa_nome"
   FROM ("public"."Contas_Plataforma" "cp"
     JOIN "public"."Empresas" "emp" ON (("cp"."empresa" = "emp"."id")));


ALTER TABLE "public"."view_contas_plataforma" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."viewcontasplataformaempresaname" AS
 SELECT "cp"."id" AS "idconta",
    "cp"."creator",
    "emp"."id" AS "empresaid",
    "emp"."name" AS "empresanome"
   FROM ("public"."Contas_Plataforma" "cp"
     JOIN "public"."Empresas" "emp" ON (("cp"."empresa" = "emp"."id")));


ALTER TABLE "public"."viewcontasplataformaempresaname" OWNER TO "postgres";


ALTER TABLE ONLY "documentsmeta2"."documents" ALTER COLUMN "id" SET DEFAULT "nextval"('"documentsmeta2"."documents_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."documentsaureaai" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."documents_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."n8n_chat_histories" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."n8n_chat_histories_id_seq"'::"regclass");



ALTER TABLE ONLY "documentsmeta2"."documents"
    ADD CONSTRAINT "documents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Ads"
    ADD CONSTRAINT "Ads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."AjusteCampanha"
    ADD CONSTRAINT "AjusteCampanha_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."BrandKit"
    ADD CONSTRAINT "BrandKit_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Campanhas"
    ADD CONSTRAINT "Campanhas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."CamposCampanhaValores"
    ADD CONSTRAINT "CamposCampanhaValores_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."CamposCampanha"
    ADD CONSTRAINT "CamposCampanha_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."CamposTemplateSetup"
    ADD CONSTRAINT "CamposTemplateSetup_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."CamposAds"
    ADD CONSTRAINT "Campos_Ads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."CamposGrupoAds"
    ADD CONSTRAINT "Campos_Grupo_Ads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Celebridade"
    ADD CONSTRAINT "Celebridade_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ContasAds"
    ADD CONSTRAINT "Contas_Ads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ContasBusiness"
    ADD CONSTRAINT "Contas_Business_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Contas_Plataforma"
    ADD CONSTRAINT "Contas_Plataforma_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Empresas"
    ADD CONSTRAINT "Empresas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Enderecos"
    ADD CONSTRAINT "Enderecos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."GruposAds"
    ADD CONSTRAINT "Grupos_Ads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Instagram"
    ADD CONSTRAINT "Instagran_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."LocalizacaoAnuncios"
    ADD CONSTRAINT "LocalizacaoAnuncios_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."MCategoria"
    ADD CONSTRAINT "MCategoria_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."MMidias"
    ADD CONSTRAINT "MMidias_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Ofertas"
    ADD CONSTRAINT "Ofertas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."PaginasAnuncio"
    ADD CONSTRAINT "Paginas_Anuncio_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Plataformas"
    ADD CONSTRAINT "Plataformas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."PreConfiguracaoPost"
    ADD CONSTRAINT "PreConfiguracaoPost_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."SatelitePreviewMidiaTemplate"
    ADD CONSTRAINT "PreviewMidia_Template_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."PreviewMidia"
    ADD CONSTRAINT "PreviewMidia_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Produto"
    ADD CONSTRAINT "Produto_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Publico"
    ADD CONSTRAINT "Publico_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Render"
    ADD CONSTRAINT "Render_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."SateliteTemplateFormato"
    ADD CONSTRAINT "SateliteTemplateFormato_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."TemplateFormatoSetup"
    ADD CONSTRAINT "TemplateFormato_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Template"
    ADD CONSTRAINT "Template_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Tiktok"
    ADD CONSTRAINT "Tiktok_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."TiposAnuncioCriados"
    ADD CONSTRAINT "TiposAnuncioCriados_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."TiposAnuncio"
    ADD CONSTRAINT "TiposAnuncio_idTipoAnuncio_key" UNIQUE ("idTipoAnuncio");



ALTER TABLE ONLY "public"."TiposAnuncio"
    ADD CONSTRAINT "TiposAnuncio_id_integer_key" UNIQUE ("id_integer");



ALTER TABLE ONLY "public"."TiposAnuncio"
    ADD CONSTRAINT "TiposAnuncio_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."TiposCampanha"
    ADD CONSTRAINT "TiposCampanha_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."Usuarios"
    ADD CONSTRAINT "Usuarios_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ValoresCamposAds"
    ADD CONSTRAINT "Valores_Campos_Ads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ValoresCamposGrupoAds"
    ADD CONSTRAINT "Valores_Campos_Grupo_Ads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."chatUsuário"
    ADD CONSTRAINT "chatUsuário_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."documentsaureaai"
    ADD CONSTRAINT "documents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."interessesAnuncios"
    ADD CONSTRAINT "interessesAnuncios_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."listasDeOfertas"
    ADD CONSTRAINT "listasDeOfertas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."logNotificacao"
    ADD CONSTRAINT "logNotificacao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."maudioPrecos"
    ADD CONSTRAINT "maudioPrecos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."mensagensChat"
    ADD CONSTRAINT "mensagensChat_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."midiasTeste"
    ADD CONSTRAINT "midiasTeste_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."n8n_chat_histories"
    ADD CONSTRAINT "n8n_chat_histories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ofertas"
    ADD CONSTRAINT "ofertas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."postagens"
    ADD CONSTRAINT "postagens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."SateliteCamposFormPreviewMidia"
    ADD CONSTRAINT "satelitecamposformpreviewmidia_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ofertaPivotada"
    ADD CONSTRAINT "tblOfertaPivotada_pkey" PRIMARY KEY ("indexOferta", "previewMidiaId");



ALTER TABLE ONLY "public"."SateliteTemplateFormato"
    ADD CONSTRAINT "unique_relation" UNIQUE ("previewMidiaId", "templateId", "templateFormatoSetupId");



CREATE OR REPLACE TRIGGER "apiCreatomateVersionMain" AFTER INSERT ON "public"."Render" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://aurea-one.bubbleapps.io/version-test/api/1.1/wf/wbsupabaserender', 'POST', '{"Content-type":"application/json"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "criandoCampanha" AFTER INSERT ON "public"."Campanhas" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://aurea-one.bubbleapps.io/version-823as/api/1.1/wf/criargrupoa/initialize', 'POST', '{"Content-type":"application/json"}', '{}', '5000');



ALTER TABLE ONLY "public"."Ads"
    ADD CONSTRAINT "Ads_campanhaId_fkey" FOREIGN KEY ("campanhaId") REFERENCES "public"."Campanhas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."Ads"
    ADD CONSTRAINT "Ads_grupoAnuncioId_fkey" FOREIGN KEY ("grupoAnuncioId") REFERENCES "public"."GruposAds"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."BrandKit"
    ADD CONSTRAINT "BrandKit_empresa_fkey" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."Campanhas"
    ADD CONSTRAINT "Campanhas_plataforma_fkey" FOREIGN KEY ("plataforma") REFERENCES "public"."Contas_Plataforma"("id");



ALTER TABLE ONLY "public"."CamposCampanhaValores"
    ADD CONSTRAINT "CamposCampanhaValores_campanha_fkey" FOREIGN KEY ("campanha") REFERENCES "public"."Campanhas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."CamposGrupoAds"
    ADD CONSTRAINT "CamposGrupoAds_plataforma_fkey" FOREIGN KEY ("plataforma") REFERENCES "public"."Plataformas"("id");



ALTER TABLE ONLY "public"."CamposTemplateSetup"
    ADD CONSTRAINT "CamposTemplateSetup_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "public"."Template"("id");



ALTER TABLE ONLY "public"."ContasAds"
    ADD CONSTRAINT "ContasAds_plataforma_fkey" FOREIGN KEY ("plataforma") REFERENCES "public"."Contas_Plataforma"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."GruposAds"
    ADD CONSTRAINT "GruposAds_campanhaId_fkey" FOREIGN KEY ("campanhaId") REFERENCES "public"."Campanhas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."GruposAds"
    ADD CONSTRAINT "GruposAds_plataforma_fkey" FOREIGN KEY ("plataforma") REFERENCES "public"."Contas_Plataforma"("id");



ALTER TABLE ONLY "public"."LocalizacaoAnuncios"
    ADD CONSTRAINT "LocalizacaoAnuncios_grupoAnuncio_fkey" FOREIGN KEY ("grupoAnuncio") REFERENCES "public"."GruposAds"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."Ofertas"
    ADD CONSTRAINT "Ofertas_lista_fkey" FOREIGN KEY ("lista") REFERENCES "public"."listasDeOfertas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."PreConfiguracaoPost"
    ADD CONSTRAINT "PreConfiguracaoPost_empresa_fkey" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."Render"
    ADD CONSTRAINT "Render_sateliteTemplateFormatoId_fkey" FOREIGN KEY ("sateliteTemplateFormatoId") REFERENCES "public"."SateliteTemplateFormato"("id");



ALTER TABLE ONLY "public"."SateliteCamposFormPreviewMidia"
    ADD CONSTRAINT "SateliteCamposFormPreviewMidia_campoTemplateSetupId_fkey" FOREIGN KEY ("campoTemplateSetupId") REFERENCES "public"."CamposTemplateSetup"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."SateliteCamposFormPreviewMidia"
    ADD CONSTRAINT "SateliteCamposFormPreviewMidia_previewMidiaId_fkey" FOREIGN KEY ("previewMidiaId") REFERENCES "public"."PreviewMidia"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."SateliteCamposFormPreviewMidia"
    ADD CONSTRAINT "SateliteCamposFormPreviewMidia_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "public"."Template"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."TemplateFormatoSetup"
    ADD CONSTRAINT "TemplateFormatoSetup_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "public"."Template"("id");



ALTER TABLE ONLY "public"."Tiktok"
    ADD CONSTRAINT "Tiktok_empresa_fkey" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."TiposAnuncioCriados"
    ADD CONSTRAINT "Tipos de Anuncio Criados_tipoAnuncio_fkey" FOREIGN KEY ("tipoAnuncio") REFERENCES "public"."TiposAnuncio"("id");



ALTER TABLE ONLY "public"."TiposAnuncioCriados"
    ADD CONSTRAINT "TiposAnuncioCriados_ads_fkey" FOREIGN KEY ("ads") REFERENCES "public"."Ads"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."TiposAnuncioCriados"
    ADD CONSTRAINT "TiposAnuncioCriados_grupoAds_fkey" FOREIGN KEY ("grupoAds") REFERENCES "public"."GruposAds"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ValoresCamposAds"
    ADD CONSTRAINT "ValoresCamposAds_ads_fkey" FOREIGN KEY ("ads") REFERENCES "public"."Ads"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ValoresCamposGrupoAds"
    ADD CONSTRAINT "ValoresCamposGrupoAds_grupoAds_fkey" FOREIGN KEY ("grupoAds") REFERENCES "public"."GruposAds"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."Ads"
    ADD CONSTRAINT "fk_ads_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Ads"
    ADD CONSTRAINT "fk_ads_contasAds" FOREIGN KEY ("contaAdsId") REFERENCES "public"."ContasAds"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Ads"
    ADD CONSTRAINT "fk_ads_tiposAnuncio" FOREIGN KEY ("tipoAnuncioId") REFERENCES "public"."TiposAnuncio"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."AjusteCampanha"
    ADD CONSTRAINT "fk_ajusteCampanha_template" FOREIGN KEY ("templateId") REFERENCES "public"."Template"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Campanhas"
    ADD CONSTRAINT "fk_campanhas_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Campanhas"
    ADD CONSTRAINT "fk_campanhas_idContaAds" FOREIGN KEY ("ContaAds") REFERENCES "public"."ContasAds"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Campanhas"
    ADD CONSTRAINT "fk_campanhas_tiposCampanha" FOREIGN KEY ("tipoCampanha") REFERENCES "public"."TiposCampanha"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."CamposAds"
    ADD CONSTRAINT "fk_camposAds_tiposAnuncio" FOREIGN KEY ("tipoAnuncioId") REFERENCES "public"."TiposAnuncio"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."CamposCampanhaValores"
    ADD CONSTRAINT "fk_camposCampanhaValores_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."CamposCampanha"
    ADD CONSTRAINT "fk_camposCampanha_plataforma" FOREIGN KEY ("plataformaId") REFERENCES "public"."Plataformas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."ContasAds"
    ADD CONSTRAINT "fk_contasAds_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."ContasBusiness"
    ADD CONSTRAINT "fk_contasBusiness_ads" FOREIGN KEY ("contasAdsId") REFERENCES "public"."ContasAds"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."ContasBusiness"
    ADD CONSTRAINT "fk_contasBusiness_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."ContasBusiness"
    ADD CONSTRAINT "fk_contasBusiness_paginas" FOREIGN KEY ("paginasAnuncioId") REFERENCES "public"."PaginasAnuncio"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Contas_Plataforma"
    ADD CONSTRAINT "fk_contasPlataforma_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Contas_Plataforma"
    ADD CONSTRAINT "fk_contasPlataforma_plataforma" FOREIGN KEY ("plataforma") REFERENCES "public"."Plataformas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Empresas"
    ADD CONSTRAINT "fk_empresas_address" FOREIGN KEY ("endereçod") REFERENCES "public"."Enderecos"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Enderecos"
    ADD CONSTRAINT "fk_enderecos_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."GruposAds"
    ADD CONSTRAINT "fk_gruposAds_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."GruposAds"
    ADD CONSTRAINT "fk_gruposAds_contasAds" FOREIGN KEY ("contaAdsId") REFERENCES "public"."ContasAds"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."GruposAds"
    ADD CONSTRAINT "fk_gruposAds_tiposAnuncio" FOREIGN KEY ("tipoAnuncioId") REFERENCES "public"."TiposAnuncio"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Instagram"
    ADD CONSTRAINT "fk_instagran_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."MMidias"
    ADD CONSTRAINT "fk_mmidias_category" FOREIGN KEY ("categoryId") REFERENCES "public"."MCategoria"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."MMidias"
    ADD CONSTRAINT "fk_mmidias_template" FOREIGN KEY ("templateId") REFERENCES "public"."Template"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."MMidias"
    ADD CONSTRAINT "fk_mmidias_templateFormato" FOREIGN KEY ("templateFormatoId") REFERENCES "public"."TemplateFormatoSetup"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Ofertas"
    ADD CONSTRAINT "fk_ofertas_produto" FOREIGN KEY ("productId") REFERENCES "public"."Produto"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."PaginasAnuncio"
    ADD CONSTRAINT "fk_paginasAnuncio_business" FOREIGN KEY ("contaBusinessPaginaId") REFERENCES "public"."ContasBusiness"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."PaginasAnuncio"
    ADD CONSTRAINT "fk_paginasAnuncio_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."PaginasAnuncio"
    ADD CONSTRAINT "fk_paginasAnuncio_instagran" FOREIGN KEY ("instagranId") REFERENCES "public"."Instagram"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."PreviewMidia"
    ADD CONSTRAINT "fk_previewMidia_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."SatelitePreviewMidiaTemplate"
    ADD CONSTRAINT "fk_previewmidia" FOREIGN KEY ("previewMidiaId") REFERENCES "public"."PreviewMidia"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."SateliteTemplateFormato"
    ADD CONSTRAINT "fk_previewmidia" FOREIGN KEY ("previewMidiaId") REFERENCES "public"."PreviewMidia"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."Produto"
    ADD CONSTRAINT "fk_produto_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Produto"
    ADD CONSTRAINT "fk_produto_creator" FOREIGN KEY ("creator") REFERENCES "public"."Usuarios"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Publico"
    ADD CONSTRAINT "fk_publico_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Render"
    ADD CONSTRAINT "fk_render_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Render"
    ADD CONSTRAINT "fk_render_mAssinatura" FOREIGN KEY ("mAssinatura") REFERENCES "public"."MMidias"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Render"
    ADD CONSTRAINT "fk_render_mBackgroundEstatica" FOREIGN KEY ("mBackgroundEstatica") REFERENCES "public"."MMidias"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Render"
    ADD CONSTRAINT "fk_render_mBackgroundOferta" FOREIGN KEY ("mBackgroundOferta") REFERENCES "public"."MMidias"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Render"
    ADD CONSTRAINT "fk_render_mCabeca" FOREIGN KEY ("mCabeca") REFERENCES "public"."MMidias"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Render"
    ADD CONSTRAINT "fk_render_mCelebridade" FOREIGN KEY ("mCelebridade") REFERENCES "public"."MMidias"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Render"
    ADD CONSTRAINT "fk_render_ofertas" FOREIGN KEY ("listOfertas") REFERENCES "public"."Ofertas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Render"
    ADD CONSTRAINT "fk_render_template" FOREIGN KEY ("templateId") REFERENCES "public"."Template"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Render"
    ADD CONSTRAINT "fk_render_template2" FOREIGN KEY ("templateId2") REFERENCES "public"."Template"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."SatelitePreviewMidiaTemplate"
    ADD CONSTRAINT "fk_template" FOREIGN KEY ("templateId") REFERENCES "public"."Template"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."SateliteTemplateFormato"
    ADD CONSTRAINT "fk_template" FOREIGN KEY ("templateId") REFERENCES "public"."Template"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."TemplateFormatoSetup"
    ADD CONSTRAINT "fk_templateFormato_creator" FOREIGN KEY ("creator") REFERENCES "public"."Usuarios"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."TemplateFormatoSetup"
    ADD CONSTRAINT "fk_templateFormato_tiposCampanha" FOREIGN KEY ("tiposCampanha") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."SateliteTemplateFormato"
    ADD CONSTRAINT "fk_templateformato" FOREIGN KEY ("templateFormatoSetupId") REFERENCES "public"."TemplateFormatoSetup"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."TiposAnuncio"
    ADD CONSTRAINT "fk_tiposAnuncio_plataforma" FOREIGN KEY ("plataformaId") REFERENCES "public"."Plataformas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."TiposCampanha"
    ADD CONSTRAINT "fk_tiposCampanha_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."TiposCampanha"
    ADD CONSTRAINT "fk_tiposCampanha_plataforma" FOREIGN KEY ("plataformaId") REFERENCES "public"."Plataformas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Usuarios"
    ADD CONSTRAINT "fk_usuarios_address" FOREIGN KEY ("addressId") REFERENCES "public"."Enderecos"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Usuarios"
    ADD CONSTRAINT "fk_usuarios_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."Usuarios"
    ADD CONSTRAINT "fk_usuarios_companyOriginal" FOREIGN KEY ("companyOriginal") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."ValoresCamposAds"
    ADD CONSTRAINT "fk_valoresCamposAds_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."ValoresCamposGrupoAds"
    ADD CONSTRAINT "fk_valoresCamposGrupoAds_company" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."interessesAnuncios"
    ADD CONSTRAINT "interessesAnuncios_grupoAds_fkey" FOREIGN KEY ("grupoAds") REFERENCES "public"."GruposAds"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."listasDeOfertas"
    ADD CONSTRAINT "listasDeOfertas_empresa_fkey" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."mensagensChat"
    ADD CONSTRAINT "mensagensChat_chat_fkey" FOREIGN KEY ("chat") REFERENCES "public"."chatUsuário"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ofertas"
    ADD CONSTRAINT "ofertas_lista_fkey" FOREIGN KEY ("lista") REFERENCES "public"."listasDeOfertas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ofertas"
    ADD CONSTRAINT "ofertas_produto_fkey" FOREIGN KEY ("produto") REFERENCES "public"."Produto"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."postagens"
    ADD CONSTRAINT "postagens_empresa_fkey" FOREIGN KEY ("empresa") REFERENCES "public"."Empresas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."postagens"
    ADD CONSTRAINT "postagens_id_campanha_fkey" FOREIGN KEY ("id_campanha") REFERENCES "public"."Campanhas"("id") ON DELETE CASCADE;



ALTER TABLE "public"."chatUsuário" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."logNotificacao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."midiasTeste" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ofertas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."postagens" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."Ads";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."BrandKit";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."Campanhas";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."CamposAds";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."CamposCampanha";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."CamposCampanhaValores";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."CamposTemplateSetup";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."Celebridade";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."ContasAds";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."Contas_Plataforma";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."Empresas";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."GruposAds";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."Instagram";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."LocalizacaoAnuncios";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."MMidias";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."Ofertas";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."PaginasAnuncio";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."PreConfiguracaoPost";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."PreviewMidia";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."Produto";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."Render";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."SateliteCamposFormPreviewMidia";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."SatelitePreviewMidiaTemplate";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."SateliteTemplateFormato";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."Template";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."TemplateFormatoSetup";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."Tiktok";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."ValoresCamposAds";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."ValoresCamposGrupoAds";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."interessesAnuncios";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."listasDeOfertas";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."logNotificacao";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."maudioPrecos";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."mensagensChat";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."n8n_chat_histories";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."ofertaPivotada";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."postagens";






GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_in"("cstring", "oid", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_in"("cstring", "oid", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_in"("cstring", "oid", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_in"("cstring", "oid", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_out"("public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_out"("public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_out"("public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_out"("public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_recv"("internal", "oid", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_recv"("internal", "oid", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_recv"("internal", "oid", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_recv"("internal", "oid", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_send"("public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_send"("public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_send"("public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_send"("public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_typmod_in"("cstring"[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_typmod_in"("cstring"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_typmod_in"("cstring"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_typmod_in"("cstring"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_in"("cstring", "oid", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_in"("cstring", "oid", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_in"("cstring", "oid", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_in"("cstring", "oid", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_out"("public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_out"("public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_out"("public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_out"("public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_recv"("internal", "oid", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_recv"("internal", "oid", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_recv"("internal", "oid", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_recv"("internal", "oid", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_send"("public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_send"("public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_send"("public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_send"("public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_typmod_in"("cstring"[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_typmod_in"("cstring"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_typmod_in"("cstring"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_typmod_in"("cstring"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_in"("cstring", "oid", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_in"("cstring", "oid", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."vector_in"("cstring", "oid", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_in"("cstring", "oid", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_out"("public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_out"("public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_out"("public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_out"("public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_recv"("internal", "oid", integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_recv"("internal", "oid", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."vector_recv"("internal", "oid", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_recv"("internal", "oid", integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_send"("public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_send"("public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_send"("public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_send"("public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_typmod_in"("cstring"[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_typmod_in"("cstring"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."vector_typmod_in"("cstring"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_typmod_in"("cstring"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_halfvec"(real[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(real[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(real[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(real[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(real[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(real[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(real[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(real[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_vector"(real[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_vector"(real[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_vector"(real[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_vector"(real[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_halfvec"(double precision[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(double precision[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(double precision[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(double precision[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(double precision[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(double precision[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(double precision[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(double precision[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_vector"(double precision[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_vector"(double precision[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_vector"(double precision[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_vector"(double precision[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_halfvec"(integer[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(integer[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(integer[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(integer[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(integer[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(integer[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(integer[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(integer[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_vector"(integer[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_vector"(integer[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_vector"(integer[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_vector"(integer[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_halfvec"(numeric[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(numeric[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(numeric[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_halfvec"(numeric[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(numeric[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(numeric[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(numeric[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_sparsevec"(numeric[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."array_to_vector"(numeric[], integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."array_to_vector"(numeric[], integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."array_to_vector"(numeric[], integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."array_to_vector"(numeric[], integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_to_float4"("public"."halfvec", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_to_float4"("public"."halfvec", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_to_float4"("public"."halfvec", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_to_float4"("public"."halfvec", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec"("public"."halfvec", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec"("public"."halfvec", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec"("public"."halfvec", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec"("public"."halfvec", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_to_sparsevec"("public"."halfvec", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_to_sparsevec"("public"."halfvec", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_to_sparsevec"("public"."halfvec", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_to_sparsevec"("public"."halfvec", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_to_vector"("public"."halfvec", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_to_vector"("public"."halfvec", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_to_vector"("public"."halfvec", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_to_vector"("public"."halfvec", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_to_halfvec"("public"."sparsevec", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_to_halfvec"("public"."sparsevec", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_to_halfvec"("public"."sparsevec", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_to_halfvec"("public"."sparsevec", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec"("public"."sparsevec", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec"("public"."sparsevec", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec"("public"."sparsevec", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec"("public"."sparsevec", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_to_vector"("public"."sparsevec", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_to_vector"("public"."sparsevec", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_to_vector"("public"."sparsevec", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_to_vector"("public"."sparsevec", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_to_float4"("public"."vector", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_to_float4"("public"."vector", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."vector_to_float4"("public"."vector", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_to_float4"("public"."vector", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_to_halfvec"("public"."vector", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_to_halfvec"("public"."vector", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."vector_to_halfvec"("public"."vector", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_to_halfvec"("public"."vector", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_to_sparsevec"("public"."vector", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_to_sparsevec"("public"."vector", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."vector_to_sparsevec"("public"."vector", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_to_sparsevec"("public"."vector", integer, boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."vector"("public"."vector", integer, boolean) TO "postgres";
GRANT ALL ON FUNCTION "public"."vector"("public"."vector", integer, boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."vector"("public"."vector", integer, boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector"("public"."vector", integer, boolean) TO "service_role";




















































































































































































GRANT ALL ON FUNCTION "public"."atualizarIndex"() TO "anon";
GRANT ALL ON FUNCTION "public"."atualizarIndex"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."atualizarIndex"() TO "service_role";



GRANT ALL ON FUNCTION "public"."binary_quantize"("public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."binary_quantize"("public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."binary_quantize"("public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."binary_quantize"("public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."binary_quantize"("public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."binary_quantize"("public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."binary_quantize"("public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."binary_quantize"("public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."cosine_distance"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."execute_sql"("query" "text", "params" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."execute_sql"("query" "text", "params" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."execute_sql"("query" "text", "params" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_column_list"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_column_list"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_column_list"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_columns"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_columns"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_columns"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_columns"("table_name_input" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_columns"("table_name_input" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_columns"("table_name_input" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_accum"(double precision[], "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_accum"(double precision[], "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_accum"(double precision[], "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_accum"(double precision[], "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_add"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_add"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_add"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_add"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_avg"(double precision[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_avg"(double precision[]) TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_avg"(double precision[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_avg"(double precision[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_cmp"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_cmp"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_cmp"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_cmp"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_combine"(double precision[], double precision[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_combine"(double precision[], double precision[]) TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_combine"(double precision[], double precision[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_combine"(double precision[], double precision[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_concat"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_concat"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_concat"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_concat"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_eq"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_eq"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_eq"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_eq"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_ge"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_ge"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_ge"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_ge"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_gt"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_gt"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_gt"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_gt"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_l2_squared_distance"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_l2_squared_distance"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_l2_squared_distance"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_l2_squared_distance"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_le"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_le"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_le"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_le"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_lt"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_lt"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_lt"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_lt"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_mul"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_mul"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_mul"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_mul"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_ne"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_ne"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_ne"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_ne"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_negative_inner_product"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_negative_inner_product"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_negative_inner_product"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_negative_inner_product"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_spherical_distance"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_spherical_distance"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_spherical_distance"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_spherical_distance"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."halfvec_sub"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."halfvec_sub"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."halfvec_sub"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."halfvec_sub"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."hamming_distance"(bit, bit) TO "postgres";
GRANT ALL ON FUNCTION "public"."hamming_distance"(bit, bit) TO "anon";
GRANT ALL ON FUNCTION "public"."hamming_distance"(bit, bit) TO "authenticated";
GRANT ALL ON FUNCTION "public"."hamming_distance"(bit, bit) TO "service_role";



GRANT ALL ON FUNCTION "public"."hnsw_bit_support"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."hnsw_bit_support"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."hnsw_bit_support"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."hnsw_bit_support"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."hnsw_halfvec_support"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."hnsw_halfvec_support"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."hnsw_halfvec_support"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."hnsw_halfvec_support"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."hnsw_sparsevec_support"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."hnsw_sparsevec_support"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."hnsw_sparsevec_support"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."hnsw_sparsevec_support"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."hnswhandler"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."hnswhandler"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."hnswhandler"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."hnswhandler"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."inner_product"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."inner_product"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."inner_product"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."inner_product"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."inner_product"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."inner_product"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."inner_product"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."inner_product"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."inner_product"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."inner_product"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."inner_product"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."inner_product"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."inserir_midia_direta"("p_name_file" "text", "p_url_file" "text", "p_os_categoria" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."inserir_midia_direta"("p_name_file" "text", "p_url_file" "text", "p_os_categoria" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."inserir_midia_direta"("p_name_file" "text", "p_url_file" "text", "p_os_categoria" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."ivfflat_bit_support"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."ivfflat_bit_support"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."ivfflat_bit_support"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ivfflat_bit_support"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."ivfflat_halfvec_support"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."ivfflat_halfvec_support"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."ivfflat_halfvec_support"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ivfflat_halfvec_support"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."ivfflathandler"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."ivfflathandler"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."ivfflathandler"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ivfflathandler"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."jaccard_distance"(bit, bit) TO "postgres";
GRANT ALL ON FUNCTION "public"."jaccard_distance"(bit, bit) TO "anon";
GRANT ALL ON FUNCTION "public"."jaccard_distance"(bit, bit) TO "authenticated";
GRANT ALL ON FUNCTION "public"."jaccard_distance"(bit, bit) TO "service_role";



GRANT ALL ON FUNCTION "public"."l1_distance"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."l1_distance"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."l1_distance"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."l1_distance"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."l1_distance"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."l1_distance"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."l1_distance"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."l1_distance"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."l1_distance"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."l1_distance"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."l1_distance"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."l1_distance"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."l2_distance"("public"."halfvec", "public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."l2_distance"("public"."halfvec", "public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."l2_distance"("public"."halfvec", "public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."l2_distance"("public"."halfvec", "public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."l2_distance"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."l2_distance"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."l2_distance"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."l2_distance"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."l2_distance"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."l2_distance"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."l2_distance"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."l2_distance"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."l2_norm"("public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."l2_norm"("public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."l2_norm"("public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."l2_norm"("public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."l2_norm"("public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."l2_norm"("public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."l2_norm"("public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."l2_norm"("public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."l2_normalize"("public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."match_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."match_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."match_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."match_meta_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."match_meta_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."match_meta_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."match_tiktok_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."match_tiktok_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."match_tiktok_documents"("query_embedding" "public"."vector", "match_count" integer, "filter" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_index_file"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_index_file"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_index_file"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_cmp"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_cmp"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_cmp"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_cmp"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_eq"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_eq"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_eq"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_eq"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_ge"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_ge"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_ge"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_ge"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_gt"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_gt"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_gt"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_gt"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_l2_squared_distance"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_l2_squared_distance"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_l2_squared_distance"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_l2_squared_distance"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_le"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_le"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_le"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_le"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_lt"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_lt"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_lt"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_lt"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_ne"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_ne"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_ne"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_ne"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."sparsevec_negative_inner_product"("public"."sparsevec", "public"."sparsevec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sparsevec_negative_inner_product"("public"."sparsevec", "public"."sparsevec") TO "anon";
GRANT ALL ON FUNCTION "public"."sparsevec_negative_inner_product"("public"."sparsevec", "public"."sparsevec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sparsevec_negative_inner_product"("public"."sparsevec", "public"."sparsevec") TO "service_role";



GRANT ALL ON FUNCTION "public"."subvector"("public"."halfvec", integer, integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."subvector"("public"."halfvec", integer, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."subvector"("public"."halfvec", integer, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."subvector"("public"."halfvec", integer, integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."subvector"("public"."vector", integer, integer) TO "postgres";
GRANT ALL ON FUNCTION "public"."subvector"("public"."vector", integer, integer) TO "anon";
GRANT ALL ON FUNCTION "public"."subvector"("public"."vector", integer, integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."subvector"("public"."vector", integer, integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_accum"(double precision[], "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_accum"(double precision[], "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_accum"(double precision[], "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_accum"(double precision[], "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_add"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_add"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_add"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_add"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_avg"(double precision[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_avg"(double precision[]) TO "anon";
GRANT ALL ON FUNCTION "public"."vector_avg"(double precision[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_avg"(double precision[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_cmp"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_cmp"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_cmp"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_cmp"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_combine"(double precision[], double precision[]) TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_combine"(double precision[], double precision[]) TO "anon";
GRANT ALL ON FUNCTION "public"."vector_combine"(double precision[], double precision[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_combine"(double precision[], double precision[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_concat"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_concat"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_concat"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_concat"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_dims"("public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_dims"("public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_dims"("public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_dims"("public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_dims"("public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_dims"("public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_dims"("public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_dims"("public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_eq"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_eq"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_eq"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_eq"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_ge"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_ge"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_ge"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_ge"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_gt"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_gt"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_gt"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_gt"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_l2_squared_distance"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_l2_squared_distance"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_l2_squared_distance"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_l2_squared_distance"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_le"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_le"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_le"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_le"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_lt"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_lt"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_lt"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_lt"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_mul"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_mul"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_mul"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_mul"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_ne"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_ne"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_ne"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_ne"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_negative_inner_product"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_negative_inner_product"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_negative_inner_product"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_negative_inner_product"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_norm"("public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_norm"("public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_norm"("public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_norm"("public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_spherical_distance"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_spherical_distance"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_spherical_distance"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_spherical_distance"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."vector_sub"("public"."vector", "public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."vector_sub"("public"."vector", "public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."vector_sub"("public"."vector", "public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."vector_sub"("public"."vector", "public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."avg"("public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."avg"("public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."avg"("public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."avg"("public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."avg"("public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."avg"("public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."avg"("public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."avg"("public"."vector") TO "service_role";



GRANT ALL ON FUNCTION "public"."sum"("public"."halfvec") TO "postgres";
GRANT ALL ON FUNCTION "public"."sum"("public"."halfvec") TO "anon";
GRANT ALL ON FUNCTION "public"."sum"("public"."halfvec") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sum"("public"."halfvec") TO "service_role";



GRANT ALL ON FUNCTION "public"."sum"("public"."vector") TO "postgres";
GRANT ALL ON FUNCTION "public"."sum"("public"."vector") TO "anon";
GRANT ALL ON FUNCTION "public"."sum"("public"."vector") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sum"("public"."vector") TO "service_role";


















GRANT ALL ON TABLE "public"."Ads" TO "anon";
GRANT ALL ON TABLE "public"."Ads" TO "authenticated";
GRANT ALL ON TABLE "public"."Ads" TO "service_role";



GRANT ALL ON TABLE "public"."AjusteCampanha" TO "anon";
GRANT ALL ON TABLE "public"."AjusteCampanha" TO "authenticated";
GRANT ALL ON TABLE "public"."AjusteCampanha" TO "service_role";



GRANT ALL ON TABLE "public"."BrandKit" TO "anon";
GRANT ALL ON TABLE "public"."BrandKit" TO "authenticated";
GRANT ALL ON TABLE "public"."BrandKit" TO "service_role";



GRANT ALL ON TABLE "public"."Campanhas" TO "anon";
GRANT ALL ON TABLE "public"."Campanhas" TO "authenticated";
GRANT ALL ON TABLE "public"."Campanhas" TO "service_role";



GRANT ALL ON TABLE "public"."CamposAds" TO "anon";
GRANT ALL ON TABLE "public"."CamposAds" TO "authenticated";
GRANT ALL ON TABLE "public"."CamposAds" TO "service_role";



GRANT ALL ON TABLE "public"."CamposCampanha" TO "anon";
GRANT ALL ON TABLE "public"."CamposCampanha" TO "authenticated";
GRANT ALL ON TABLE "public"."CamposCampanha" TO "service_role";



GRANT ALL ON TABLE "public"."CamposCampanhaValores" TO "anon";
GRANT ALL ON TABLE "public"."CamposCampanhaValores" TO "authenticated";
GRANT ALL ON TABLE "public"."CamposCampanhaValores" TO "service_role";



GRANT ALL ON TABLE "public"."CamposGrupoAds" TO "anon";
GRANT ALL ON TABLE "public"."CamposGrupoAds" TO "authenticated";
GRANT ALL ON TABLE "public"."CamposGrupoAds" TO "service_role";



GRANT ALL ON TABLE "public"."CamposTemplateSetup" TO "anon";
GRANT ALL ON TABLE "public"."CamposTemplateSetup" TO "authenticated";
GRANT ALL ON TABLE "public"."CamposTemplateSetup" TO "service_role";



GRANT ALL ON TABLE "public"."Celebridade" TO "anon";
GRANT ALL ON TABLE "public"."Celebridade" TO "authenticated";
GRANT ALL ON TABLE "public"."Celebridade" TO "service_role";



GRANT ALL ON TABLE "public"."ContasAds" TO "anon";
GRANT ALL ON TABLE "public"."ContasAds" TO "authenticated";
GRANT ALL ON TABLE "public"."ContasAds" TO "service_role";



GRANT ALL ON TABLE "public"."ContasBusiness" TO "anon";
GRANT ALL ON TABLE "public"."ContasBusiness" TO "authenticated";
GRANT ALL ON TABLE "public"."ContasBusiness" TO "service_role";



GRANT ALL ON TABLE "public"."Contas_Plataforma" TO "anon";
GRANT ALL ON TABLE "public"."Contas_Plataforma" TO "authenticated";
GRANT ALL ON TABLE "public"."Contas_Plataforma" TO "service_role";



GRANT ALL ON TABLE "public"."Empresas" TO "anon";
GRANT ALL ON TABLE "public"."Empresas" TO "authenticated";
GRANT ALL ON TABLE "public"."Empresas" TO "service_role";



GRANT ALL ON TABLE "public"."Enderecos" TO "anon";
GRANT ALL ON TABLE "public"."Enderecos" TO "authenticated";
GRANT ALL ON TABLE "public"."Enderecos" TO "service_role";



GRANT ALL ON TABLE "public"."GruposAds" TO "anon";
GRANT ALL ON TABLE "public"."GruposAds" TO "authenticated";
GRANT ALL ON TABLE "public"."GruposAds" TO "service_role";



GRANT ALL ON TABLE "public"."Instagram" TO "anon";
GRANT ALL ON TABLE "public"."Instagram" TO "authenticated";
GRANT ALL ON TABLE "public"."Instagram" TO "service_role";



GRANT ALL ON TABLE "public"."LocalizacaoAnuncios" TO "anon";
GRANT ALL ON TABLE "public"."LocalizacaoAnuncios" TO "authenticated";
GRANT ALL ON TABLE "public"."LocalizacaoAnuncios" TO "service_role";



GRANT ALL ON TABLE "public"."MCategoria" TO "anon";
GRANT ALL ON TABLE "public"."MCategoria" TO "authenticated";
GRANT ALL ON TABLE "public"."MCategoria" TO "service_role";



GRANT ALL ON TABLE "public"."MMidias" TO "anon";
GRANT ALL ON TABLE "public"."MMidias" TO "authenticated";
GRANT ALL ON TABLE "public"."MMidias" TO "service_role";



GRANT ALL ON TABLE "public"."Ofertas" TO "anon";
GRANT ALL ON TABLE "public"."Ofertas" TO "authenticated";
GRANT ALL ON TABLE "public"."Ofertas" TO "service_role";



GRANT ALL ON TABLE "public"."PaginasAnuncio" TO "anon";
GRANT ALL ON TABLE "public"."PaginasAnuncio" TO "authenticated";
GRANT ALL ON TABLE "public"."PaginasAnuncio" TO "service_role";



GRANT ALL ON TABLE "public"."Plataformas" TO "anon";
GRANT ALL ON TABLE "public"."Plataformas" TO "authenticated";
GRANT ALL ON TABLE "public"."Plataformas" TO "service_role";



GRANT ALL ON TABLE "public"."PreConfiguracaoPost" TO "anon";
GRANT ALL ON TABLE "public"."PreConfiguracaoPost" TO "authenticated";
GRANT ALL ON TABLE "public"."PreConfiguracaoPost" TO "service_role";



GRANT ALL ON TABLE "public"."PreviewMidia" TO "anon";
GRANT ALL ON TABLE "public"."PreviewMidia" TO "authenticated";
GRANT ALL ON TABLE "public"."PreviewMidia" TO "service_role";



GRANT ALL ON TABLE "public"."Produto" TO "anon";
GRANT ALL ON TABLE "public"."Produto" TO "authenticated";
GRANT ALL ON TABLE "public"."Produto" TO "service_role";



GRANT ALL ON TABLE "public"."Publico" TO "anon";
GRANT ALL ON TABLE "public"."Publico" TO "authenticated";
GRANT ALL ON TABLE "public"."Publico" TO "service_role";



GRANT ALL ON TABLE "public"."Render" TO "anon";
GRANT ALL ON TABLE "public"."Render" TO "authenticated";
GRANT ALL ON TABLE "public"."Render" TO "service_role";



GRANT ALL ON TABLE "public"."SateliteCamposFormPreviewMidia" TO "anon";
GRANT ALL ON TABLE "public"."SateliteCamposFormPreviewMidia" TO "authenticated";
GRANT ALL ON TABLE "public"."SateliteCamposFormPreviewMidia" TO "service_role";



GRANT ALL ON TABLE "public"."SatelitePreviewMidiaTemplate" TO "anon";
GRANT ALL ON TABLE "public"."SatelitePreviewMidiaTemplate" TO "authenticated";
GRANT ALL ON TABLE "public"."SatelitePreviewMidiaTemplate" TO "service_role";



GRANT ALL ON TABLE "public"."SateliteTemplateFormato" TO "anon";
GRANT ALL ON TABLE "public"."SateliteTemplateFormato" TO "authenticated";
GRANT ALL ON TABLE "public"."SateliteTemplateFormato" TO "service_role";



GRANT ALL ON TABLE "public"."Template" TO "anon";
GRANT ALL ON TABLE "public"."Template" TO "authenticated";
GRANT ALL ON TABLE "public"."Template" TO "service_role";



GRANT ALL ON TABLE "public"."TemplateFormatoSetup" TO "anon";
GRANT ALL ON TABLE "public"."TemplateFormatoSetup" TO "authenticated";
GRANT ALL ON TABLE "public"."TemplateFormatoSetup" TO "service_role";



GRANT ALL ON TABLE "public"."Tiktok" TO "anon";
GRANT ALL ON TABLE "public"."Tiktok" TO "authenticated";
GRANT ALL ON TABLE "public"."Tiktok" TO "service_role";



GRANT ALL ON TABLE "public"."TiposAnuncio" TO "anon";
GRANT ALL ON TABLE "public"."TiposAnuncio" TO "authenticated";
GRANT ALL ON TABLE "public"."TiposAnuncio" TO "service_role";



GRANT ALL ON TABLE "public"."TiposAnuncioCriados" TO "anon";
GRANT ALL ON TABLE "public"."TiposAnuncioCriados" TO "authenticated";
GRANT ALL ON TABLE "public"."TiposAnuncioCriados" TO "service_role";



GRANT ALL ON SEQUENCE "public"."TiposAnuncio_id_integer_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."TiposAnuncio_id_integer_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."TiposAnuncio_id_integer_seq" TO "service_role";



GRANT ALL ON TABLE "public"."TiposCampanha" TO "anon";
GRANT ALL ON TABLE "public"."TiposCampanha" TO "authenticated";
GRANT ALL ON TABLE "public"."TiposCampanha" TO "service_role";



GRANT ALL ON TABLE "public"."Usuarios" TO "anon";
GRANT ALL ON TABLE "public"."Usuarios" TO "authenticated";
GRANT ALL ON TABLE "public"."Usuarios" TO "service_role";



GRANT ALL ON TABLE "public"."ValoresCamposAds" TO "anon";
GRANT ALL ON TABLE "public"."ValoresCamposAds" TO "authenticated";
GRANT ALL ON TABLE "public"."ValoresCamposAds" TO "service_role";



GRANT ALL ON TABLE "public"."ValoresCamposGrupoAds" TO "anon";
GRANT ALL ON TABLE "public"."ValoresCamposGrupoAds" TO "authenticated";
GRANT ALL ON TABLE "public"."ValoresCamposGrupoAds" TO "service_role";



GRANT ALL ON TABLE "public"."chatUsuário" TO "anon";
GRANT ALL ON TABLE "public"."chatUsuário" TO "authenticated";
GRANT ALL ON TABLE "public"."chatUsuário" TO "service_role";



GRANT ALL ON TABLE "public"."documentsaureaai" TO "anon";
GRANT ALL ON TABLE "public"."documentsaureaai" TO "authenticated";
GRANT ALL ON TABLE "public"."documentsaureaai" TO "service_role";



GRANT ALL ON SEQUENCE "public"."documents_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."documents_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."documents_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."interessesAnuncios" TO "anon";
GRANT ALL ON TABLE "public"."interessesAnuncios" TO "authenticated";
GRANT ALL ON TABLE "public"."interessesAnuncios" TO "service_role";



GRANT ALL ON TABLE "public"."listasDeOfertas" TO "anon";
GRANT ALL ON TABLE "public"."listasDeOfertas" TO "authenticated";
GRANT ALL ON TABLE "public"."listasDeOfertas" TO "service_role";



GRANT ALL ON TABLE "public"."logNotificacao" TO "anon";
GRANT ALL ON TABLE "public"."logNotificacao" TO "authenticated";
GRANT ALL ON TABLE "public"."logNotificacao" TO "service_role";



GRANT ALL ON TABLE "public"."maudioPrecos" TO "anon";
GRANT ALL ON TABLE "public"."maudioPrecos" TO "authenticated";
GRANT ALL ON TABLE "public"."maudioPrecos" TO "service_role";



GRANT ALL ON TABLE "public"."mensagensChat" TO "anon";
GRANT ALL ON TABLE "public"."mensagensChat" TO "authenticated";
GRANT ALL ON TABLE "public"."mensagensChat" TO "service_role";



GRANT ALL ON TABLE "public"."midiasTeste" TO "anon";
GRANT ALL ON TABLE "public"."midiasTeste" TO "authenticated";
GRANT ALL ON TABLE "public"."midiasTeste" TO "service_role";



GRANT ALL ON TABLE "public"."n8n_chat_histories" TO "anon";
GRANT ALL ON TABLE "public"."n8n_chat_histories" TO "authenticated";
GRANT ALL ON TABLE "public"."n8n_chat_histories" TO "service_role";



GRANT ALL ON SEQUENCE "public"."n8n_chat_histories_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."n8n_chat_histories_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."n8n_chat_histories_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."ofertaPivotada" TO "anon";
GRANT ALL ON TABLE "public"."ofertaPivotada" TO "authenticated";
GRANT ALL ON TABLE "public"."ofertaPivotada" TO "service_role";



GRANT ALL ON TABLE "public"."ofertas" TO "anon";
GRANT ALL ON TABLE "public"."ofertas" TO "authenticated";
GRANT ALL ON TABLE "public"."ofertas" TO "service_role";



GRANT ALL ON TABLE "public"."postagens" TO "anon";
GRANT ALL ON TABLE "public"."postagens" TO "authenticated";
GRANT ALL ON TABLE "public"."postagens" TO "service_role";



GRANT ALL ON TABLE "public"."viewOfertaAgrupada" TO "anon";
GRANT ALL ON TABLE "public"."viewOfertaAgrupada" TO "authenticated";
GRANT ALL ON TABLE "public"."viewOfertaAgrupada" TO "service_role";



GRANT ALL ON TABLE "public"."viewOfertaEstruturada" TO "anon";
GRANT ALL ON TABLE "public"."viewOfertaEstruturada" TO "authenticated";
GRANT ALL ON TABLE "public"."viewOfertaEstruturada" TO "service_role";



GRANT ALL ON TABLE "public"."viewOfertaPivotada" TO "anon";
GRANT ALL ON TABLE "public"."viewOfertaPivotada" TO "authenticated";
GRANT ALL ON TABLE "public"."viewOfertaPivotada" TO "service_role";



GRANT ALL ON TABLE "public"."viewSocialAccount" TO "anon";
GRANT ALL ON TABLE "public"."viewSocialAccount" TO "authenticated";
GRANT ALL ON TABLE "public"."viewSocialAccount" TO "service_role";



GRANT ALL ON TABLE "public"."view_contas_plataforma" TO "anon";
GRANT ALL ON TABLE "public"."view_contas_plataforma" TO "authenticated";
GRANT ALL ON TABLE "public"."view_contas_plataforma" TO "service_role";



GRANT ALL ON TABLE "public"."viewcontasplataformaempresaname" TO "anon";
GRANT ALL ON TABLE "public"."viewcontasplataformaempresaname" TO "authenticated";
GRANT ALL ON TABLE "public"."viewcontasplataformaempresaname" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
