-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_graphql";
CREATE EXTENSION IF NOT EXISTS "pgtap";
CREATE EXTENSION IF NOT EXISTS "http";
CREATE EXTENSION IF NOT EXISTS "vector";

-- Create custom types
DO $$ BEGIN
    CREATE TYPE "osStatus" AS ENUM ('Ativo', 'Inativo');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "osFormatos" AS ENUM ('16x9', '9x16', '1x1', '4x5', 'Null');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "osCategoria" AS ENUM (
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
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "osConteudo" AS ENUM (
        'Feed',
        'Reels',
        'Storys',
        'Carrossel',
        'Video',
        'Imagem'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "osFieldTypeStandard" AS ENUM (
        'Text',
        'Currency',
        'Date'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "osMaterial" AS ENUM (
        'Filme 15s',
        'Filme 30s',
        'Null'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "osPlataformas" AS ENUM (
        'Facebook',
        'Instagram',
        'Tiktok'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "osStatusRender" AS ENUM (
        'Renderizando',
        'Finalizado',
        'Erro'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "osTrafficType" AS ENUM (
        'Organico',
        'Pago'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "osTypeField" AS ENUM (
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
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "osTypeMidia" AS ENUM (
        'Video',
        'Estatica',
        'Radio'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "osTypeNotification" AS ENUM (
        'PreviewMidia',
        'ErrorRender',
        'NewTemplate'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "user_status" AS ENUM (
        'ACTIVE',
        'INACTIVE',
        'PENDING'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create sequences
CREATE SEQUENCE IF NOT EXISTS "documents_id_seq";
CREATE SEQUENCE IF NOT EXISTS "n8n_chat_histories_id_seq";

-- Create tables
CREATE TABLE IF NOT EXISTS "Ads" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "creator" text,
    "empresa" uuid,
    "createdDate" date DEFAULT CURRENT_DATE,
    "idAds" text,
    "contaAdsId" uuid,
    "templateText" text,
    "grupoAnuncioId" uuid,
    "name" text,
    "notaAds" integer,
    "tipoAnuncioId" uuid,
    "ultimoInsigthCpc" numeric,
    "ultimoInsigthClicks" numeric,
    "ultimoInsigthCpm" numeric,
    "ultimoInsigthAlcance" numeric,
    "ultimoInsigthCtr" numeric,
    "ultimoInsigthImpressao" numeric,
    "ultimoInsigthTempoVisualizacao" numeric,
    "ultimoInsigthValorGasto" numeric,
    "campanhaId" uuid,
    "contaPlataforma" uuid,
    "urlMidia" text
);

CREATE TABLE IF NOT EXISTS "AjusteCampanha" (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    assinaturaSpeed numeric,
    cabecaSpeed numeric,
    bebidaSpeed numeric,
    createdDate date DEFAULT CURRENT_DATE,
    modifiedDate date DEFAULT CURRENT_DATE,
    txtLegalSpeed numeric,
    templateId uuid
);

CREATE TABLE IF NOT EXISTS "BrandKit" (
    cor_primaria text,
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    empresa uuid,
    fonte text,
    logo text,
    cor_terciaria text,
    cor_secundaria text
);

CREATE TABLE IF NOT EXISTS "Campanhas" (
    plataforma uuid,
    createdDate date DEFAULT CURRENT_DATE,
    ContaAds uuid,
    inicioCampanha date,
    terminoCampanha date,
    tipoCampanha uuid,
    idCampanha text,
    nomeCampanha text,
    creator text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    empresa uuid
);

CREATE TABLE IF NOT EXISTS "CamposAds" (
    tipoAnuncioId uuid,
    createdDate date DEFAULT CURRENT_DATE,
    descricaoCampo text,
    parametroAPI text,
    id uuid NOT NULL DEFAULT uuid_generate_v4()
);

CREATE TABLE IF NOT EXISTS "CamposCampanha" (
    valorPadrao text,
    usuarioPreencher boolean,
    plataformaId uuid,
    descricaoCampo text,
    createdDate date DEFAULT CURRENT_DATE,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    parametroAPI text,
    tipoCampo text
);

CREATE TABLE IF NOT EXISTS "CamposCampanhaValores" (
    typeField text,
    ordem numeric,
    campanha uuid,
    usuarioPreencher boolean,
    valorpadrao text,
    createdDate date DEFAULT CURRENT_DATE,
    empresa uuid,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    descricaoCampo text,
    parametroAPI text,
    valorCampo text,
    creator text
);

CREATE TABLE IF NOT EXISTS "CamposGrupoAds" (
    descricaoCampo text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    valorPadrao text,
    createdDate date DEFAULT CURRENT_DATE,
    plataforma uuid,
    usuarioPreencher boolean,
    tipoDado text,
    sequencia text,
    parametroAPI text
);

CREATE TABLE IF NOT EXISTS "CamposTemplateSetup" (
    visivelUsuario boolean,
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    fieldCreatomate text,
    fieldName text,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    templateId uuid NOT NULL DEFAULT gen_random_uuid(),
    indexOferta text
);

CREATE TABLE IF NOT EXISTS "Celebridade" (
    pro boolean DEFAULT false,
    filtreCelebridade text,
    description text,
    urlCelebridade text,
    urlThumb text,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    name text,
    indexID numeric,
    free boolean DEFAULT false,
    ativo boolean DEFAULT false
);

CREATE TABLE IF NOT EXISTS "ContasAds" (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    idContaAds text,
    creator text,
    empresa uuid,
    nomeContaAds text,
    createdDate date DEFAULT CURRENT_DATE,
    contaBusinessId uuid,
    plataforma uuid,
    identifyId text,
    plataformaId text
);

CREATE TABLE IF NOT EXISTS "ContasBusiness" (
    paginasAnuncioId uuid,
    creator text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    empresa uuid,
    name text,
    businessID text,
    createdDate date DEFAULT CURRENT_DATE,
    contasAdsId uuid
);

CREATE TABLE IF NOT EXISTS "Contas_Plataforma" (
    createdDate date DEFAULT CURRENT_DATE,
    identifyId text,
    name text,
    idConta text,
    emailConta text,
    accessToken text,
    creator text,
    plataformaId text,
    refreshToken text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    empresa uuid,
    active boolean DEFAULT true,
    plataforma uuid,
    expire_token timestamp with time zone
);

CREATE TABLE IF NOT EXISTS "Empresas" (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    email text,
    logo text,
    creator text,
    name text NOT NULL,
    tradeName text,
    cnpj text,
    setorAtuacao text,
    telefone text,
    endereçod uuid,
    createdDate date DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS "Enderecos" (
    number text,
    city text,
    street text,
    creator text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    empresa uuid,
    createdDate date DEFAULT CURRENT_DATE,
    district text,
    cep text
);

CREATE TABLE IF NOT EXISTS "GruposAds" (
    plataforma uuid,
    generoAnuncio text,
    idadeMax text,
    idadeMin text,
    creator text,
    idGrupoAds text,
    nomeGrupo text,
    campanhaId uuid,
    tipoAnuncioId uuid,
    contaAdsId uuid,
    createdDate date DEFAULT CURRENT_DATE,
    empresa uuid,
    id uuid NOT NULL DEFAULT uuid_generate_v4()
);

CREATE TABLE IF NOT EXISTS "Instagram" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "creator" text,
    "empresa" uuid,
    "createdDate" date DEFAULT CURRENT_DATE,
    "idAnuncio" text,
    "nomeInstagran" text,
    "idIdentificacao" text,
    "fotoPerfil" text,
    "nomeUsuario" text,
    "access_token" text,
    "status" "osStatus" NOT NULL DEFAULT 'Ativo',
    "idContaAds" text
);

CREATE TABLE IF NOT EXISTS "LocalizacaoAnuncios" (
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    chaveLocal text,
    grupoAnuncio uuid,
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    raio numeric,
    type text,
    descricao text
);

CREATE TABLE IF NOT EXISTS "MCategoria" (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    name character varying(255)
);

CREATE TABLE IF NOT EXISTS "MMidias" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "nameFile" character varying,
    "urlFile" character varying,
    "indexFile" integer,
    "active" boolean DEFAULT true,
    "thumbUrl" text,
    "templateId" uuid,
    "templateFormatoId" uuid,
    "createdBy" character varying,
    "createdDate" timestamp without time zone DEFAULT now(),
    "categoryId" uuid,
    "osCategoria" "osTypeMidia",
    "osMaterial" "osTypeMidia",
    "osFormatos" "osFormatos",
    "fieldCreatomate" text,
    "ativo" boolean,
    "osTypeMidiaTemplate" "osTypeMidia",
    "filterCelebridade" text
);

CREATE TABLE IF NOT EXISTS "Ofertas" (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    updatedAt timestamp without time zone DEFAULT now(),
    discount numeric,
    productId uuid,
    createdAt timestamp without time zone DEFAULT now(),
    position smallint,
    lista uuid,
    price text,
    description text,
    title character varying(255)
);

CREATE TABLE IF NOT EXISTS "PaginasAnuncio" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "creator" text,
    "empresa" uuid,
    "createdDate" date DEFAULT CURRENT_DATE,
    "idPagina" text,
    "nomePagina" text,
    "contaBusinessPaginaId" uuid,
    "instagranId" uuid,
    "pictureUrl" text,
    "accessToken" text,
    "status" "osStatus" DEFAULT 'Ativo',
    "idContaAds" text
);

CREATE TABLE IF NOT EXISTS "Plataformas" (
    idPlataforma text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    createdDate date DEFAULT CURRENT_DATE,
    active boolean DEFAULT true,
    platform text,
    description text,
    logoImage text,
    apiVersion text
);

CREATE TABLE IF NOT EXISTS "PreConfiguracaoPost" (
    empresa uuid,
    hashtags text,
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    impacto text,
    marcacoes text
);

CREATE TABLE IF NOT EXISTS "PreviewMidia" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "listMCabeca" uuid[],
    "listMBackgroundOfertas" uuid[],
    "listMAssinatura" uuid[],
    "listMBackgroundOferta" uuid[],
    "listMCelebridades" uuid[],
    "listOfertas" uuid[],
    "listTypeMidia" "osTypeMidia"[],
    "listMaterial" "osTypeMidia"[],
    "listRender" uuid[],
    "listPraca" text,
    "geoLocalizacao" text,
    "osStatusFilme" character varying,
    "mSelo" character varying,
    "textoLegal" text,
    "createdBy" character varying,
    "createdDate" timestamp without time zone DEFAULT now(),
    "uuid" uuid,
    "creator" text,
    "empresa" uuid,
    "templateId" uuid,
    "testeMauro" jsonb,
    "editFinalizada" boolean,
    "filterCeleb" text,
    "categoriaSelecionada" text
);

CREATE TABLE IF NOT EXISTS "Produto" (
    urlImg text,
    description text,
    typeProduct character varying(50),
    ofertaSemana boolean DEFAULT false,
    precificador text NOT NULL,
    ativo boolean,
    empresa uuid,
    creator uuid,
    updatedAt timestamp without time zone DEFAULT now(),
    createdAt timestamp without time zone DEFAULT now(),
    audioPreco text,
    subcategoria text,
    categoria text,
    tempoMillisegundos text,
    precoCentavo text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    precoReal text,
    urlAudio text,
    skuAurea text
);

CREATE TABLE IF NOT EXISTS "Publico" (
    geoLocalizacao text,
    creator text,
    gender text,
    empresa uuid,
    age text,
    id uuid NOT NULL DEFAULT uuid_generate_v4()
);

CREATE TABLE IF NOT EXISTS "Render" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "mCabeca" uuid,
    "mBackgroundOferta" uuid,
    "mAssinatura" uuid,
    "mBackgroundEstatica" uuid,
    "mCelebridade" uuid,
    "templateId" uuid,
    "templateId2" uuid,
    "status" character varying,
    "videoUrl" text,
    "colorText" text,
    "listOfertas" uuid,
    "templateFormatoId" uuid,
    "osTypeMidia" "osTypeMidia",
    "createdAt" timestamp without time zone DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo'::text),
    "updatedAt" timestamp with time zone,
    "geoLocalizacao" text,
    "creator" text,
    "empresa" uuid,
    "mCabecaUrl" text,
    "mBackgroundUrl" text,
    "mAssinaturaUrl" text,
    "mTrilhaUrl" text,
    "previewMidiaId" uuid,
    "thumbnailUrl" text,
    "osFormatos" "osFormatos",
    "filterCeleb" text,
    "sateliteTemplateFormatoId" uuid,
    "idCreatomateTemplate" text,
    "osStatusRender" "osStatus",
    "errorMsg" text,
    "postAgendado" boolean DEFAULT false,
    "renderNoticado" boolean DEFAULT false,
    "nameRender" text
);

CREATE TABLE IF NOT EXISTS "SateliteCamposFormPreviewMidia" (
    campoTemplateSetupId uuid,
    visivelUsuario boolean,
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    previewMidiaId uuid,
    created_at timestamp without time zone DEFAULT now(),
    templateId uuid,
    valorCampo text,
    indexOferta text,
    fieldCreatomate text
);

CREATE TABLE IF NOT EXISTS "SatelitePreviewMidiaTemplate" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "previewMidiaId" uuid NOT NULL,
    "templateId" uuid NOT NULL,
    "MMidiasId" uuid NOT NULL,
    "created_at" timestamp without time zone DEFAULT now(),
    "osMaterial" "osTypeMidia",
    "osCategoria" "osTypeMidia",
    "osTypeMidiaTemplate" "osTypeMidia",
    "osFormatos" "osFormatos",
    "urlFile" text,
    "fieldCreatomate" text,
    "templateFormatoId" uuid,
    "filterCelebridade" text
);

CREATE TABLE IF NOT EXISTS "SateliteTemplateFormato" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "previewMidiaId" uuid NOT NULL,
    "templateId" uuid NOT NULL,
    "templateFormatoSetupId" uuid NOT NULL,
    "created_at" timestamp without time zone DEFAULT now(),
    "idCreatomateTemplate" text,
    "osFormatos" "osFormatos",
    "osTypeMidia" "osTypeMidia",
    "active" boolean,
    "urlThumb" text,
    "name" text,
    "selectClient" boolean DEFAULT true,
    "selectClientFront" boolean DEFAULT false,
    "categoriaSelecionada" "osTypeMidia"
);

CREATE TABLE IF NOT EXISTS "Template" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "active" boolean DEFAULT true,
    "colorLetras" text,
    "thumbUrl" text,
    "optionText" text,
    "createdDate" timestamp without time zone DEFAULT now(),
    "osMaterial" "osTypeMidia"[],
    "osTypeMidia" "osTypeMidia"[],
    "listMmidias" uuid[],
    "collumn" text[]
);

CREATE TABLE IF NOT EXISTS "TemplateFormatoSetup" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "active" boolean DEFAULT true,
    "tiposCampanha" uuid,
    "jsonData" text,
    "osRedeSociais" character varying,
    "name" text,
    "creator" uuid,
    "osTypeMidia" "osTypeMidia",
    "idCreatomate" text,
    "osFormato" "osFormatos" DEFAULT '16x9',
    "templateId" uuid DEFAULT gen_random_uuid(),
    "urlThumb" text,
    "quantidadeOfertas" text,
    "editaCelebridade" boolean,
    "editarOferta" boolean,
    "previa" text
);

CREATE TABLE IF NOT EXISTS "Tiktok" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "creator" text,
    "empresa" uuid,
    "createdDate" date DEFAULT CURRENT_DATE,
    "accessToken" text,
    "refreshToken" text,
    "fotoPerfil" text,
    "nomeUsuario" text,
    "status" "osStatus" NOT NULL DEFAULT 'Ativo',
    "identifyId" text,
    "contaAds" text
);

CREATE TABLE IF NOT EXISTS "TiposAnuncio" (
    idTipoAnuncio numeric,
    description text,
    plataforma text,
    localPublicar text,
    variacoesTesteAz integer,
    plataformaId uuid,
    nomeVisualizacao text,
    active boolean DEFAULT true,
    id_integer integer NOT NULL,
    createdDate date DEFAULT CURRENT_DATE,
    capa text,
    id uuid NOT NULL DEFAULT uuid_generate_v4()
);

CREATE TABLE IF NOT EXISTS "TiposAnuncioCriados" (
    ads uuid,
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    grupoAds uuid,
    tipoAnuncio uuid
);

CREATE TABLE IF NOT EXISTS "TiposCampanha" (
    createdDate date DEFAULT CURRENT_DATE,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    empresa uuid,
    idTipoCampanha integer,
    plataformaId uuid,
    creator text,
    nomeTipoCampanha text,
    parametroAPI text
);

CREATE TABLE IF NOT EXISTS "Usuarios" (
    createdDate date DEFAULT CURRENT_DATE,
    cpf text,
    plan text,
    secondName text,
    name text,
    creator text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    empresa uuid,
    addressId uuid
);

CREATE TABLE IF NOT EXISTS "ValoresCamposAds" (
    creator text,
    descricao text,
    ordem numeric,
    usuarioPreencher boolean,
    ads uuid,
    createdDate date DEFAULT CURRENT_DATE,
    empresa uuid,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    parametroAPI text,
    valorCampo text
);

CREATE TABLE IF NOT EXISTS "ValoresCamposGrupoAds" (
    usuarioPrencher boolean,
    ordem numeric,
    createdDate date DEFAULT CURRENT_DATE,
    descrição text,
    tipoDado text,
    empresa uuid,
    grupoAds uuid,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    creator text,
    sequencia text,
    valorCampo text,
    parametroAPI text
);

CREATE TABLE IF NOT EXISTS "chatUsuário" (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    criador text
);

CREATE TABLE IF NOT EXISTS "documentsaureaai" (
    content text,
    metadata jsonb,
    id bigint NOT NULL DEFAULT nextval('documents_id_seq'::regclass),
    embedding vector(1536)
);

CREATE TABLE IF NOT EXISTS "interessesAnuncios" (
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    nomeInteresse text,
    idInteresse text,
    grupoAds uuid
);

CREATE TABLE IF NOT EXISTS "listasDeOfertas" (
    dataTermino date,
    nome text,
    status text,
    creator text,
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    empresa uuid,
    dataInicio date
);

CREATE TABLE IF NOT EXISTS "logNotificacao" (
    "created_at" timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo'::text),
    "previewMidiaId" uuid DEFAULT gen_random_uuid(),
    "creator" text,
    "osTypeNotification" "osTypeNotification",
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "visualizado" boolean DEFAULT false
);

CREATE TABLE IF NOT EXISTS "maudioPrecos" (
    ativo boolean,
    createdDate date,
    filterFieldReais text,
    nameFile text,
    createdBy text,
    filterFieldCentavos text,
    precoCompleto text,
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    urlAudio text
);

CREATE TABLE IF NOT EXISTS "mensagensChat" (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    mensagemUsuário text,
    chat uuid,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    creador text,
    mensagemIA text
);

CREATE TABLE IF NOT EXISTS "midiasTeste" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "created_at" timestamp with time zone NOT NULL DEFAULT now(),
    "url_midia" text,
    "thumbnail" text,
    "formato" "osFormatos",
    "midiaType" "osTypeMidia"
);

CREATE TABLE IF NOT EXISTS "n8n_chat_histories" (
    message jsonb NOT NULL,
    id integer NOT NULL DEFAULT nextval('n8n_chat_histories_id_seq'::regclass),
    session_id character varying(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS "ofertaPivotada" (
    oferta_visible text,
    imagemProduto text,
    audioProduto text,
    audioPreco text,
    indexOferta text NOT NULL,
    precoRealOferta text,
    textoLegalOferta text,
    tituloOferta text,
    "finalBebida.visible" text,
    previewMidiaId uuid NOT NULL,
    precoCentavosOferta text
);

CREATE TABLE IF NOT EXISTS "ofertas" (
    valor text,
    produto uuid,
    lista uuid,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    posicao smallint
);

CREATE TABLE IF NOT EXISTS "order_items" (
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    price numeric NOT NULL,
    quantity integer NOT NULL,
    product_id uuid NOT NULL,
    order_id uuid NOT NULL,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "orders" (
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    status text NOT NULL DEFAULT 'pending'::text,
    user_id uuid NOT NULL,
    total_amount numeric NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "postagens" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "created_at" timestamp with time zone NOT NULL DEFAULT now(),
    "creator" text,
    "empresa" uuid,
    "url_midia" text,
    "formato" "osFormatos",
    "midia_type" "osTypeMidia",
    "plataforma" text,
    "thumbnail" text,
    "programado" boolean,
    "data_postagem" timestamp with time zone DEFAULT now(),
    "nome_campanha" text,
    "traffic_type" "osTypeMidia",
    "conteudo" text,
    "id_social_account" text,
    "descricao" text,
    "hashtags" text,
    "status" text DEFAULT 'postado'::text,
    "id_campanha" uuid
);

CREATE TABLE IF NOT EXISTS "products" (
    description text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    price numeric NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "social_accounts" (
    provider_id text NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    user_id uuid NOT NULL,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    provider text NOT NULL
);

CREATE TABLE IF NOT EXISTS "users" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "email" text NOT NULL,
    "name" text,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "pictureUrl" text,
    "status" "user_status" DEFAULT 'PENDING'
);

CREATE TABLE IF NOT EXISTS "viewOfertaAgrupada" (
    campos json,
    indexOferta text
);

CREATE TABLE IF NOT EXISTS "viewOfertaEstruturada" (
    campotemplatesetupid text,
    created_at timestamp without time zone,
    fieldcreatomate text,
    previewmidiaid text,
    valorcampo text,
    visivelusuario boolean,
    indexOferta text,
    id text,
    templateid text
);

CREATE TABLE IF NOT EXISTS "viewSocialAccount" (
    "id" uuid,
    "provider" text,
    "provider_id" text,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "user_id" uuid,
    "email" text,
    "name" text,
    "pictureUrl" text,
    "status" "user_status"
);

CREATE TABLE IF NOT EXISTS "viewSocialAccounts_ads" (
    "social_account_id" uuid,
    "provider" text,
    "provider_id" text,
    "social_account_created_at" timestamp with time zone,
    "social_account_updated_at" timestamp with time zone,
    "user_id" uuid,
    "email" text,
    "name" text,
    "pictureUrl" text,
    "status" "user_status",
    "ad_id" uuid,
    "ad_title" text,
    "ad_description" text,
    "ad_created_at" timestamp with time zone,
    "ad_updated_at" timestamp with time zone
);

CREATE TABLE IF NOT EXISTS "view_contas_plataforma" (
    empresa_nome text,
    empresa_id uuid,
    creator text,
    id_conta uuid
);

CREATE TABLE IF NOT EXISTS "viewcontasplataformaempresaname" (
    idconta uuid,
    empresanome text,
    empresaid uuid,
    creator text
);

-- Enable Row Level Security
ALTER TABLE IF EXISTS "public"."users" ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS "public"."social_accounts" ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS "public"."ads" ENABLE ROW LEVEL SECURITY; 