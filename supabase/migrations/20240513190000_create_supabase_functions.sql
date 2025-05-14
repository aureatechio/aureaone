-- Create required schemas
CREATE SCHEMA IF NOT EXISTS "supabase_functions";

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";
CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "vector" WITH SCHEMA "public";
CREATE EXTENSION IF NOT EXISTS "http" WITH SCHEMA "supabase_functions";

-- Drop existing types if they exist
DO $$ BEGIN
    DROP TYPE IF EXISTS osStatus CASCADE;
    DROP TYPE IF EXISTS osStatusRender CASCADE;
    DROP TYPE IF EXISTS osTrafficType CASCADE;
    DROP TYPE IF EXISTS osCategoria CASCADE;
    DROP TYPE IF EXISTS osConteudo CASCADE;
    DROP TYPE IF EXISTS osFieldTypeStandard CASCADE;
    DROP TYPE IF EXISTS osFormatos CASCADE;
    DROP TYPE IF EXISTS osMaterial CASCADE;
    DROP TYPE IF EXISTS osPlataformas CASCADE;
    DROP TYPE IF EXISTS osTypeField CASCADE;
    DROP TYPE IF EXISTS osTypeMidia CASCADE;
    DROP TYPE IF EXISTS osTypeNotification CASCADE;
EXCEPTION
    WHEN others THEN null;
END $$;

-- Create ALL ENUM types first
CREATE TYPE osStatus AS ENUM (
  'Ativo',
  'Inativo'
);

CREATE TYPE osStatusRender AS ENUM (
  'Renderizando',
  'Finalizado',
  'Erro'
);

CREATE TYPE osTrafficType AS ENUM (
  'Organico',
  'Pago'
);

CREATE TYPE osCategoria AS ENUM (
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

CREATE TYPE osConteudo AS ENUM (
  'Feed',
  'Reels',
  'Storys',
  'Carrossel',
  'Video',
  'Imagem'
);

CREATE TYPE osFieldTypeStandard AS ENUM (
  'Text',
  'Currency',
  'Date'
);

CREATE TYPE osFormatos AS ENUM (
  '16x9',
  '9x16',
  '1x1',
  '4x5',
  'Null'
);

CREATE TYPE osMaterial AS ENUM (
  'Filme 15s',
  'Filme 30s',
  'Null'
);

CREATE TYPE osPlataformas AS ENUM (
  'Facebook',
  'Instagram',
  'Tiktok'
);

CREATE TYPE osTypeField AS ENUM (
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

CREATE TYPE osTypeMidia AS ENUM (
  'Video',
  'Estatica',
  'Radio'
);

CREATE TYPE osTypeNotification AS ENUM (
  'PreviewMidia',
  'ErrorRender',
  'NewTemplate'
);

-- Create Tables
CREATE TABLE IF NOT EXISTS public."Ads" (
  "ultimoInsigthCtr" numeric,
  "idAds" text,
  "ultimoInsigthImpressao" numeric,
  "ultimoInsigthTempoVisualizacao" numeric,
  "contaPlataforma" uuid,
  "campanhaId" uuid,
  "ultimoInsigthValorGasto" numeric,
  "createdDate" date,
  "contaAdsId" uuid,
  id uuid NOT NULL,
  "grupoAnuncioId" uuid,
  empresa uuid,
  "notaAds" int4,
  "tipoAnuncioId" uuid,
  "templateText" text,
  name text,
  "urlMidia" text,
  "ultimoInsigthCpc" numeric,
  "ultimoInsigthClicks" numeric,
  "ultimoInsigthCpm" numeric,
  "ultimoInsigthAlcance" numeric,
  creator text
);

CREATE TABLE IF NOT EXISTS public."AjusteCampanha" (
  "bebidaSpeed" numeric,
  "createdDate" date,
  id uuid NOT NULL,
  "assinaturaSpeed" numeric,
  "modifiedDate" date,
  "txtLegalSpeed" numeric,
  "templateId" uuid,
  "cabecaSpeed" numeric
);

CREATE TABLE IF NOT EXISTS public."BrandKit" (
  cor_primaria text,
  logo text,
  cor_terciaria text,
  created_at timestamptz NOT NULL,
  cor_secundaria text,
  id uuid NOT NULL,
  empresa uuid,
  fonte text
);

CREATE TABLE IF NOT EXISTS public."Campanhas" (
  plataforma uuid,
  "terminoCampanha" date,
  "idCampanha" text,
  "nomeCampanha" text,
  "inicioCampanha" date,
  "ContaAds" uuid,
  "createdDate" date,
  creator text,
  empresa uuid,
  "tipoCampanha" uuid,
  id uuid NOT NULL
);

CREATE TABLE IF NOT EXISTS public."CamposAds" (
  "parametroAPI" text,
  id uuid NOT NULL,
  "createdDate" date,
  "tipoAnuncioId" uuid,
  "descricaoCampo" text
);

CREATE TABLE IF NOT EXISTS public."CamposCampanha" (
  "valorPadrao" text,
  id uuid NOT NULL,
  "createdDate" date,
  "plataformaId" uuid,
  "usuarioPreencher" bool,
  "descricaoCampo" text,
  "tipoCampo" text,
  "parametroAPI" text
);

CREATE TABLE IF NOT EXISTS public."CamposCampanhaValores" (
  id uuid NOT NULL,
  creator text,
  "valorCampo" text,
  "parametroAPI" text,
  "descricaoCampo" text,
  valorpadrao text,
  "typeField" text,
  ordem numeric,
  campanha uuid,
  "usuarioPreencher" bool,
  "createdDate" date,
  empresa uuid
);

CREATE TABLE IF NOT EXISTS public."CamposGrupoAds" (
  "tipoDado" text,
  sequencia text,
  plataforma uuid,
  "valorPadrao" text,
  "usuarioPreencher" bool,
  "parametroAPI" text,
  "descricaoCampo" text,
  id uuid NOT NULL,
  "createdDate" date
);

CREATE TABLE IF NOT EXISTS public."CamposTemplateSetup" (
  "fieldCreatomate" text,
  "indexOferta" text,
  created_at timestamptz NOT NULL,
  "visivelUsuario" bool,
  "templateId" uuid NOT NULL,
  "fieldName" text,
  id uuid NOT NULL
);

CREATE TABLE IF NOT EXISTS public."Celebridade" (
  id uuid NOT NULL,
  "urlCelebridade" text,
  "filtreCelebridade" text,
  "urlThumb" text,
  created_at timestamptz NOT NULL,
  description text,
  ativo bool,
  pro bool,
  name text,
  free bool,
  "indexID" numeric
);

CREATE TABLE IF NOT EXISTS public."ContasAds" (
  id uuid NOT NULL,
  "idContaAds" text,
  "identifyId" text,
  plataforma uuid,
  "contaBusinessId" uuid,
  "plataformaId" text,
  "nomeContaAds" text,
  "createdDate" date,
  empresa uuid,
  creator text
);

CREATE TABLE IF NOT EXISTS public."ContasBusiness" (
  empresa uuid,
  "businessID" text,
  creator text,
  name text,
  "contasAdsId" uuid,
  "createdDate" date,
  "paginasAnuncioId" uuid,
  id uuid NOT NULL
);

CREATE TABLE IF NOT EXISTS public."Contas_Plataforma" (
  id uuid NOT NULL,
  plataforma uuid,
  "createdDate" date,
  expire_token timestamptz,
  empresa uuid,
  "emailConta" text,
  "accessToken" text,
  "plataformaId" text,
  creator text,
  name text,
  "identifyId" text,
  "refreshToken" text,
  active bool,
  "idConta" text
);

CREATE TABLE IF NOT EXISTS public."Empresas" (
  telefone text,
  email text,
  logo text,
  cnpj text,
  "tradeName" text,
  "endereçod" uuid,
  name text NOT NULL,
  creator text,
  id uuid NOT NULL,
  "setorAtuacao" text,
  "createdDate" date
);

CREATE TABLE IF NOT EXISTS public."Enderecos" (
  "createdDate" date,
  street text,
  empresa uuid,
  district text,
  city text,
  id uuid NOT NULL,
  cep text,
  number text,
  creator text
);

CREATE TABLE IF NOT EXISTS public."GruposAds" (
  "idadeMin" text,
  id uuid NOT NULL,
  empresa uuid,
  "createdDate" date,
  "contaAdsId" uuid,
  "tipoAnuncioId" uuid,
  "campanhaId" uuid,
  plataforma uuid,
  "nomeGrupo" text,
  creator text,
  "idadeMax" text,
  "generoAnuncio" text,
  "idGrupoAds" text
);

CREATE TABLE IF NOT EXISTS public."Instagram" (
  id uuid NOT NULL,
  status osStatus NOT NULL,
  "fotoPerfil" text,
  "nomeUsuario" text,
  empresa uuid,
  "createdDate" date,
  access_token text,
  "idAnuncio" text,
  "nomeInstagran" text,
  creator text,
  "idContaAds" text,
  "idIdentificacao" text
);

CREATE TABLE IF NOT EXISTS public."LocalizacaoAnuncios" (
  "grupoAnuncio" uuid,
  created_at timestamptz NOT NULL,
  descricao text,
  "chaveLocal" text,
  type text,
  id uuid NOT NULL,
  raio numeric
);

CREATE TABLE IF NOT EXISTS public."MCategoria" (
  id uuid NOT NULL,
  name varchar(255)
);

CREATE TABLE IF NOT EXISTS public."MMidias" (
  "osCategoria" osCategoria,
  "osMaterial" osMaterial,
  "nameFile" varchar(255),
  "fieldCreatomate" text,
  "osFormatos" osFormatos,
  ativo bool,
  "osTypeMidiaTemplate" osTypeMidia,
  "templateFormatoId" uuid,
  "createdDate" timestamp,
  "indexFile" int4,
  "filterCelebridade" text,
  "templateId" uuid,
  active bool,
  id uuid NOT NULL,
  "urlFile" varchar,
  "categoryId" uuid,
  "thumbUrl" text,
  "createdBy" varchar
);

CREATE TABLE IF NOT EXISTS public."Ofertas" (
  "updatedAt" timestamp,
  title varchar(255),
  description text,
  price text,
  id uuid NOT NULL,
  discount numeric,
  "productId" uuid,
  "createdAt" timestamp,
  lista uuid,
  "position" int2
);

CREATE TABLE IF NOT EXISTS public."PaginasAnuncio" (
  status osStatus,
  "instagranId" uuid,
  "contaBusinessPaginaId" uuid,
  "createdDate" date,
  id uuid NOT NULL,
  empresa uuid,
  "idContaAds" text,
  "accessToken" text,
  "pictureUrl" text,
  "nomePagina" text,
  "idPagina" text,
  creator text
);

CREATE TABLE IF NOT EXISTS public."Plataformas" (
  active bool,
  "createdDate" date,
  id uuid NOT NULL,
  "apiVersion" text,
  "logoImage" text,
  platform text,
  description text,
  "idPlataforma" text
);

CREATE TABLE IF NOT EXISTS public."PreConfiguracaoPost" (
  marcacoes text,
  id uuid NOT NULL,
  created_at timestamptz NOT NULL,
  empresa uuid,
  hashtags text,
  impacto text
);

CREATE TABLE IF NOT EXISTS public."PreviewMidia" (
  empresa uuid,
  "textoLegal" text,
  "mSelo" varchar(255),
  creator text,
  "listMCelebridades" uuid[],
  "osStatusFilme" varchar(50),
  "geoLocalizacao" text,
  "categoriaSelecionada" text,
  "editFinalizada" bool,
  "listPraca" text,
  "testeMauro" jsonb,
  "templateId" uuid,
  "listOfertas" uuid[],
  "listTypeMidia" uuid[],
  "listMBackgroundOfertas" uuid[],
  "listMaterial" uuid[],
  "listMAssinatura" uuid[],
  "listMBackgroundOferta" uuid[],
  "listRender" uuid[],
  "filterCeleb" text,
  "createdDate" timestamp,
  id uuid NOT NULL,
  "listMCabeca" uuid[],
  uuid uuid,
  "createdBy" varchar
);

CREATE TABLE IF NOT EXISTS public."Produto" (
  "createdAt" timestamp,
  creator uuid,
  "precoCentavo" text,
  "precoReal" text,
  "urlAudio" text,
  "tempoMillisegundos" text,
  "updatedAt" timestamp,
  "skuAurea" text,
  "urlImg" text,
  description text,
  categoria text,
  subcategoria text,
  "audioPreco" text,
  "typeProduct" varchar(50),
  precificador text NOT NULL,
  id uuid NOT NULL,
  "ofertaSemana" bool,
  ativo bool,
  empresa uuid
);

CREATE TABLE IF NOT EXISTS public."Publico" (
  gender text,
  id uuid NOT NULL,
  "geoLocalizacao" text,
  creator text,
  empresa uuid,
  age text
);

CREATE TABLE IF NOT EXISTS public."Render" (
  "nameRender" text,
  "previewMidiaId" uuid,
  "templateFormatoId" uuid,
  "mCelebridade" uuid,
  "osFormatos" osFormatos,
  "listOfertas" uuid,
  "osTypeMidia" osTypeMidia,
  "templateId" uuid,
  "sateliteTemplateFormatoId" uuid,
  id uuid NOT NULL,
  "mCabecaUrl" text,
  "geoLocalizacao" text,
  "errorMsg" text,
  "colorText" text,
  "videoUrl" text,
  status varchar(50),
  "renderNoticado" bool,
  "templateId2" uuid,
  "idCreatomateTemplate" text,
  "filterCeleb" text,
  "thumbnailUrl" text,
  "mTrilhaUrl" text,
  "mAssinaturaUrl" text,
  "mBackgroundUrl" text,
  creator text,
  "createdAt" timestamp,
  "updatedAt" timestamptz,
  "mBackgroundEstatica" uuid,
  "mBackgroundOferta" uuid,
  empresa uuid,
  "mCabeca" uuid,
  "mAssinatura" uuid,
  "osStatusRender" osStatusRender,
  "postAgendado" bool
);

CREATE TABLE IF NOT EXISTS public."SateliteCamposFormPreviewMidia" (
  "indexOferta" text,
  "templateId" uuid,
  id uuid NOT NULL,
  "campoTemplateSetupId" uuid,
  "previewMidiaId" uuid,
  "fieldCreatomate" text,
  "visivelUsuario" bool,
  "valorCampo" text,
  created_at timestamp
);

CREATE TABLE IF NOT EXISTS public."SatelitePreviewMidiaTemplate" (
  "templateId" uuid NOT NULL,
  created_at timestamp,
  "osMaterial" osMaterial,
  "osCategoria" osCategoria,
  "osTypeMidiaTemplate" osTypeMidia,
  "osFormatos" osFormatos,
  "templateFormatoId" uuid,
  id uuid NOT NULL,
  "previewMidiaId" uuid NOT NULL,
  "MMidiasId" uuid NOT NULL,
  "urlFile" text,
  "fieldCreatomate" text,
  "filterCelebridade" text
);

CREATE TABLE IF NOT EXISTS public."SateliteTemplateFormato" (
  "previewMidiaId" uuid NOT NULL,
  id uuid NOT NULL,
  "selectClient" bool,
  active bool,
  "osTypeMidia" osTypeMidia,
  "osFormatos" osFormatos,
  created_at timestamp,
  name text,
  "urlThumb" text,
  "templateFormatoSetupId" uuid NOT NULL,
  "templateId" uuid NOT NULL,
  "idCreatomateTemplate" text,
  "categoriaSelecionada" osCategoria,
  "selectClientFront" bool
);

CREATE TABLE IF NOT EXISTS public."Template" (
  "listMmidias" uuid[],
  "osTypeMidia" osTypeMidia[],
  "osMaterial" osMaterial[],
  "colorLetras" text,
  "thumbUrl" text,
  "createdDate" timestamp,
  id uuid NOT NULL,
  active bool,
  "optionText" text,
  collumn text[]
);

CREATE TABLE IF NOT EXISTS public."TemplateFormatoSetup" (
  "templateId" uuid,
  "urlThumb" text,
  "quantidadeOfertas" text,
  previa text,
  id uuid NOT NULL,
  "osRedeSociais" varchar(50),
  "jsonData" text,
  "idCreatomate" text,
  active bool,
  "tiposCampanha" uuid,
  creator uuid,
  "editarOferta" bool,
  "editaCelebridade" bool,
  name text,
  "osTypeMidia" osTypeMidia,
  "osFormato" osFormatos
);

CREATE TABLE IF NOT EXISTS public."Tiktok" (
  empresa uuid,
  "createdDate" date,
  id uuid NOT NULL,
  status osStatus NOT NULL,
  creator text,
  "accessToken" text,
  "refreshToken" text,
  "fotoPerfil" text,
  "nomeUsuario" text,
  "contaAds" text,
  "identifyId" text
);

CREATE TABLE IF NOT EXISTS public."TiposAnuncio" (
  "createdDate" date,
  id_integer int4 NOT NULL,
  active bool,
  "plataformaId" uuid,
  id uuid NOT NULL,
  capa text,
  "variacoesTesteAz" int4,
  "localPublicar" text,
  plataforma text,
  description text,
  "nomeVisualizacao" text,
  "idTipoAnuncio" numeric
);

CREATE TABLE IF NOT EXISTS public."TiposAnuncioCriados" (
  "tipoAnuncio" uuid,
  ads uuid,
  created_at timestamptz NOT NULL,
  "grupoAds" uuid,
  id uuid NOT NULL
);

CREATE TABLE IF NOT EXISTS public."TiposCampanha" (
  "parametroAPI" text,
  creator text,
  "plataformaId" uuid,
  id uuid NOT NULL,
  "idTipoCampanha" int4,
  "createdDate" date,
  empresa uuid,
  "nomeTipoCampanha" text
);

CREATE TABLE IF NOT EXISTS public."Usuarios" (
  empresa uuid,
  id uuid NOT NULL,
  creator text,
  name text,
  "secondName" text,
  plan text,
  cpf text,
  "addressId" uuid,
  "createdDate" date
);

CREATE TABLE IF NOT EXISTS public."ValoresCamposAds" (
  creator text,
  "usuarioPreencher" bool,
  ads uuid,
  "createdDate" date,
  empresa uuid,
  ordem numeric,
  id uuid NOT NULL,
  descricao text,
  "parametroAPI" text,
  "valorCampo" text
);

CREATE TABLE IF NOT EXISTS public."ValoresCamposGrupoAds" (
  ordem numeric,
  "parametroAPI" text,
  "createdDate" date,
  "grupoAds" uuid,
  creator text,
  "valorCampo" text,
  "usuarioPrencher" bool,
  id uuid NOT NULL,
  empresa uuid,
  sequencia text,
  "tipoDado" text,
  "descrição" text
);

CREATE TABLE IF NOT EXISTS public."chatUsuário" (
  criador text,
  created_at timestamptz NOT NULL,
  id uuid NOT NULL
);

CREATE TABLE IF NOT EXISTS public.documentsaureaai (
  embedding vector,
  id int8 NOT NULL,
  content text,
  metadata jsonb
);

CREATE TABLE IF NOT EXISTS public."interessesAnuncios" (
  "nomeInteresse" text,
  id uuid NOT NULL,
  created_at timestamptz NOT NULL,
  "idInteresse" text,
  "grupoAds" uuid
);

CREATE TABLE IF NOT EXISTS public."listasDeOfertas" (
  creator text,
  id uuid NOT NULL,
  created_at timestamptz NOT NULL,
  nome text,
  status text,
  "dataTermino" date,
  "dataInicio" date,
  empresa uuid
);

CREATE TABLE IF NOT EXISTS public."logNotificacao" (
  "previewMidiaId" uuid,
  created_at timestamptz NOT NULL,
  visualizado bool,
  "osTypeNotification" osTypeNotification,
  id uuid NOT NULL,
  creator text
);

CREATE TABLE IF NOT EXISTS public."maudioPrecos" (
  id uuid NOT NULL,
  "filterFieldReais" text,
  "urlAudio" text,
  "filterFieldCentavos" text,
  "createdBy" text,
  "precoCompleto" text,
  "nameFile" text,
  ativo bool,
  "createdDate" date
);

CREATE TABLE IF NOT EXISTS public."mensagensChat" (
  created_at timestamptz NOT NULL,
  id uuid NOT NULL,
  creador text,
  "mensagemIA" text,
  "mensagemUsuário" text,
  chat uuid
);

CREATE TABLE IF NOT EXISTS public."midiasTeste" (
  thumbnail text,
  created_at timestamptz NOT NULL,
  id uuid NOT NULL,
  formato osFormatos,
  "midiaType" osTypeMidia,
  url_midia text
);

CREATE TABLE IF NOT EXISTS public.n8n_chat_histories (
  id int4 NOT NULL,
  message jsonb NOT NULL,
  session_id varchar(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS public."ofertaPivotada" (
  "imagemProduto" text,
  "indexOferta" text NOT NULL,
  "audioPreco" text,
  "previewMidiaId" uuid NOT NULL,
  "audioProduto" text,
  oferta_visible text,
  "precoCentavosOferta" text,
  "precoRealOferta" text,
  "textoLegalOferta" text,
  "tituloOferta" text,
  "finalBebida.visible" text
);

CREATE TABLE IF NOT EXISTS public.ofertas (
  id uuid NOT NULL,
  created_at timestamptz NOT NULL,
  valor text,
  posicao int2,
  produto uuid,
  lista uuid
);

CREATE TABLE IF NOT EXISTS public.order_items (
  updated_at timestamptz,
  id uuid NOT NULL,
  order_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity int4 NOT NULL,
  price numeric NOT NULL,
  created_at timestamptz
);

CREATE TABLE IF NOT EXISTS public.orders (
  status text NOT NULL,
  id uuid NOT NULL,
  user_id uuid NOT NULL,
  total_amount numeric NOT NULL,
  created_at timestamptz,
  updated_at timestamptz
);

CREATE TABLE IF NOT EXISTS public.postagens (
  status text,
  hashtags text,
  descricao text,
  id_social_account text,
  conteudo text,
  nome_campanha text,
  thumbnail text,
  plataforma text,
  url_midia text,
  creator text,
  id_campanha uuid,
  traffic_type osTrafficType,
  data_postagem timestamptz,
  programado bool,
  midia_type osTypeMidia,
  formato osFormatos,
  empresa uuid,
  created_at timestamptz NOT NULL,
  id uuid NOT NULL
);

CREATE TABLE IF NOT EXISTS public.products (
  name text NOT NULL,
  updated_at timestamptz,
  created_at timestamptz,
  price numeric NOT NULL,
  id uuid NOT NULL,
  description text
);

CREATE TABLE IF NOT EXISTS public.users (
  email text NOT NULL,
  created_at timestamptz,
  id uuid NOT NULL,
  name text,
  updated_at timestamptz
);

-- Create Views
CREATE OR REPLACE VIEW public."viewOfertaAgrupada" AS
SELECT 
  jsonb_build_object(
    'valorCampo', "valorCampo",
    'fieldCreatomate', "fieldCreatomate",
    'visivelUsuario', "visivelUsuario"
  )::json as campos,
  "indexOferta"
FROM "SateliteCamposFormPreviewMidia"
GROUP BY "indexOferta", "valorCampo", "fieldCreatomate", "visivelUsuario";

CREATE OR REPLACE VIEW public."viewOfertaEstruturada" AS
SELECT 
  "previewMidiaId"::text as previewmidiaid,
  "valorCampo" as valorcampo,
  "campoTemplateSetupId"::text as campotemplatesetupid,
  "fieldCreatomate" as fieldcreatomate,
  created_at,
  "visivelUsuario" as visivelusuario,
  "indexOferta",
  id::text,
  "templateId"::text as templateid
FROM "SateliteCamposFormPreviewMidia";

CREATE OR REPLACE VIEW public."viewSocialAccount" AS
SELECT 
  p."contaBusinessPaginaId" as "idContaBusiness",
  p."creator" as "criador",
  p."pictureUrl" as "fotoPerfil",
  p."idPagina" as "idPagina",
  p."nomePagina" as "nomePagina",
  p."accessToken" as "tokenAcesso",
  p."id" as "id",
  p."empresa" as "empresa",
  p."status"::osStatus as "status"
FROM "PaginasAnuncio" p;

CREATE OR REPLACE VIEW public."viewSocialAccounts_ads" AS
SELECT 
  plataforma::osPlataformas,
  status::osStatus,
  empresa,
  id,
  "contaAds",
  access_token,
  "nomePagina",
  "idPagina",
  "fotoPerfil",
  creator,
  "dataConexao"::date
FROM "PaginasAnuncio";

CREATE OR REPLACE VIEW public.view_contas_plataforma AS
SELECT 
  e.id as empresa_id,
  cp.creator,
  e.name as empresa_nome,
  cp.id as id_conta
FROM "Contas_Plataforma" cp
JOIN "Empresas" e ON e.id = cp.empresa;

CREATE OR REPLACE VIEW public.viewcontasplataformaempresaname AS
SELECT 
  cp.creator,
  e.name as empresanome,
  e.id as empresaid,
  cp.id as idconta
FROM "Contas_Plataforma" cp
JOIN "Empresas" e ON e.id = cp.empresa;

-- Add Primary Keys for remaining tables
ALTER TABLE "chatUsuário" ADD PRIMARY KEY (id);
ALTER TABLE documentsaureaai ADD PRIMARY KEY (id);
ALTER TABLE "interessesAnuncios" ADD PRIMARY KEY (id);
ALTER TABLE "listasDeOfertas" ADD PRIMARY KEY (id);
ALTER TABLE "logNotificacao" ADD PRIMARY KEY (id);
ALTER TABLE "maudioPrecos" ADD PRIMARY KEY (id);
ALTER TABLE "mensagensChat" ADD PRIMARY KEY (id);
ALTER TABLE "midiasTeste" ADD PRIMARY KEY (id);
ALTER TABLE n8n_chat_histories ADD PRIMARY KEY (id);
ALTER TABLE ofertas ADD PRIMARY KEY (id);
ALTER TABLE order_items ADD PRIMARY KEY (id);
ALTER TABLE orders ADD PRIMARY KEY (id);
ALTER TABLE postagens ADD PRIMARY KEY (id);
ALTER TABLE products ADD PRIMARY KEY (id);
ALTER TABLE users ADD PRIMARY KEY (id);

-- Create Functions
CREATE OR REPLACE FUNCTION get_columns(table_name_input text)
RETURNS text AS $$
BEGIN
  RETURN (
    SELECT string_agg(column_name, ', ')
    FROM information_schema.columns
    WHERE table_name = table_name_input
    AND table_schema = 'public'
  );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_column_list()
RETURNS TABLE (column_name text) AS $$
BEGIN
  RETURN QUERY
  SELECT c.column_name::text
  FROM information_schema.columns c
  WHERE c.table_schema = 'public'
  ORDER BY c.table_name, c.ordinal_position;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION inserir_midia_direta(p_name_file text, p_url_file text, p_os_categoria text)
RETURNS jsonb AS $$
DECLARE
  v_result jsonb;
BEGIN
  INSERT INTO "MMidias" ("nameFile", "urlFile", "osCategoria", "createdDate", id)
  VALUES (p_name_file, p_url_file, p_os_categoria::osCategoria, NOW(), gen_random_uuid())
  RETURNING jsonb_build_object(
    'id', id,
    'nameFile', "nameFile",
    'urlFile', "urlFile",
    'osCategoria', "osCategoria"
  ) INTO v_result;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notify_new_render()
RETURNS trigger AS $$
BEGIN
  -- Notify the channel with the new record data
  PERFORM pg_notify(
    'new_render',
    json_build_object(
      'record', row_to_json(NEW),
      'type', TG_OP,
      'table', TG_TABLE_NAME,
      'schema', TG_TABLE_SCHEMA
    )::text
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_index_file()
RETURNS trigger AS $$
BEGIN
  NEW."indexFile" = (
    SELECT COALESCE(MAX("indexFile"), 0) + 1
    FROM "MMidias"
    WHERE "templateId" = NEW."templateId"
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION atualizarIndex()
RETURNS trigger AS $$
DECLARE
  v_max_index integer;
BEGIN
  -- Get the maximum index for the template
  SELECT COALESCE(MAX("indexFile"), 0) INTO v_max_index
  FROM "MMidias"
  WHERE "templateId" = OLD."templateId";
  
  -- Update indexes for all files after the deleted one
  UPDATE "MMidias"
  SET "indexFile" = "indexFile" - 1
  WHERE "templateId" = OLD."templateId"
  AND "indexFile" > OLD."indexFile";
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Create Triggers
CREATE TRIGGER render_notify_trigger
  AFTER INSERT ON "public"."Render"
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_render();

CREATE TRIGGER set_index_file_trigger
  BEFORE INSERT ON "public"."MMidias"
  FOR EACH ROW
  EXECUTE FUNCTION set_index_file();

CREATE TRIGGER atualizar_index_trigger
  AFTER DELETE ON "public"."MMidias"
  FOR EACH ROW
  EXECUTE FUNCTION atualizarIndex();
