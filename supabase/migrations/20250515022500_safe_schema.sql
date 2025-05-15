-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_graphql";
CREATE EXTENSION IF NOT EXISTS "pgtap";
CREATE EXTENSION IF NOT EXISTS "http";

-- Create custom types
DO $$ BEGIN
    CREATE TYPE osStatus AS ENUM ('Ativo', 'Inativo');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE osFormatos AS ENUM ('16x9', '9x16', '1x1', '4x5');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE user_status AS ENUM ('PENDING', 'ACTIVE', 'INACTIVE');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE osTypeMidia AS ENUM ('BACKGROUND', 'CABECA', 'ASSINATURA', 'BACKGROUND_OFERTA');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE osTypeNotification AS ENUM ('RENDER_COMPLETE', 'RENDER_ERROR');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create sequences
CREATE SEQUENCE IF NOT EXISTS documents_id_seq;
CREATE SEQUENCE IF NOT EXISTS n8n_chat_histories_id_seq;

-- Create tables
CREATE TABLE IF NOT EXISTS "Ads" (
    contaAdsId uuid,
    ultimoInsigthValorGasto numeric,
    campanhaId uuid,
    contaPlataforma uuid,
    creator text,
    templateText text,
    name text,
    urlMidia text,
    createdDate date DEFAULT CURRENT_DATE,
    empresa uuid,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    notaAds integer,
    tipoAnuncioId uuid,
    idAds text,
    ultimoInsigthCpc numeric,
    ultimoInsigthClicks numeric,
    ultimoInsigthCpm numeric,
    ultimoInsigthAlcance numeric,
    ultimoInsigthCtr numeric,
    ultimoInsigthImpressao numeric,
    grupoAnuncioId uuid,
    ultimoInsigthTempoVisualizacao numeric
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
    nomeUsuario text,
    creator text,
    access_token text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    empresa uuid,
    createdDate date DEFAULT CURRENT_DATE,
    status osStatus NOT NULL DEFAULT 'Ativo',
    idContaAds text,
    fotoPerfil text,
    idIdentificacao text,
    idAnuncio text,
    nomeInstagran text
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
    ativo boolean,
    createdBy character varying,
    templateFormatoId uuid,
    createdDate timestamp without time zone DEFAULT now(),
    nameFile character varying(255),
    urlFile character varying,
    filterCelebridade text,
    thumbUrl text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    indexFile integer,
    fieldCreatomate text,
    active boolean DEFAULT true,
    templateId uuid,
    categoryId uuid,
    osCategoria text,
    osMaterial text,
    osFormatos osFormatos,
    osTypeMidiaTemplate osTypeMidia
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
    nomePagina text,
    idContaAds text,
    idPagina text,
    status osStatus DEFAULT 'Ativo',
    instagranId uuid,
    contaBusinessPaginaId uuid,
    createdDate date DEFAULT CURRENT_DATE,
    empresa uuid,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    accessToken text,
    creator text,
    pictureUrl text
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
    createdBy character varying,
    templateId uuid,
    filterCeleb text,
    categoriaSelecionada text,
    listMAssinatura text[],
    textoLegal text,
    creator text,
    listMBackgroundOfertas text[],
    listMCabeca text[],
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    testeMauro jsonb,
    editFinalizada boolean,
    createdDate timestamp without time zone DEFAULT now(),
    mSelo character varying(255),
    listRender text[],
    listOfertas text[],
    osStatusFilme character varying(50),
    geoLocalizacao text,
    empresa uuid,
    listMaterial text[],
    listMCelebridades text[],
    listPraca text,
    listMBackgroundOferta text[],
    listTypeMidia text[],
    uuid uuid
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
    mCelebridade uuid,
    nameRender text,
    errorMsg text,
    idCreatomateTemplate text,
    filterCeleb text,
    thumbnailUrl text,
    mTrilhaUrl text,
    mAssinaturaUrl text,
    mBackgroundUrl text,
    mCabecaUrl text,
    creator text,
    geoLocalizacao text,
    colorText text,
    videoUrl text,
    status character varying(50),
    mBackgroundOferta uuid,
    mCabeca uuid,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    listOfertas uuid,
    templateId2 uuid,
    templateId uuid,
    mAssinatura uuid,
    mBackgroundEstatica uuid,
    renderNoticado boolean DEFAULT false,
    postAgendado boolean DEFAULT false,
    osStatusRender text,
    sateliteTemplateFormatoId uuid,
    osFormatos osFormatos,
    previewMidiaId uuid,
    empresa uuid,
    updatedAt timestamp with time zone,
    createdAt timestamp without time zone DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo'::text),
    osTypeMidia osTypeMidia,
    templateFormatoId uuid
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
    osTypeMidiaTemplate osTypeMidia,
    fieldCreatomate text,
    previewMidiaId uuid NOT NULL,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    osFormatos osFormatos,
    filterCelebridade text,
    templateFormatoId uuid,
    osCategoria text,
    osMaterial text,
    created_at timestamp without time zone DEFAULT now(),
    MMidiasId uuid NOT NULL,
    templateId uuid NOT NULL,
    urlFile text
);

CREATE TABLE IF NOT EXISTS "SateliteTemplateFormato" (
    osTypeMidia osTypeMidia,
    name text,
    idCreatomateTemplate text,
    urlThumb text,
    categoriaSelecionada text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    selectClientFront boolean DEFAULT false,
    previewMidiaId uuid NOT NULL,
    templateId uuid NOT NULL,
    selectClient boolean DEFAULT true,
    templateFormatoSetupId uuid NOT NULL,
    active boolean,
    created_at timestamp without time zone DEFAULT now(),
    osFormatos osFormatos
);

CREATE TABLE IF NOT EXISTS "Template" (
    listMmidias text[],
    osTypeMidia text[],
    osMaterial text[],
    collumn text[],
    createdDate timestamp without time zone DEFAULT now(),
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    active boolean DEFAULT true,
    optionText text,
    colorLetras text,
    thumbUrl text
);

CREATE TABLE IF NOT EXISTS "TemplateFormatoSetup" (
    urlThumb text,
    previa text,
    jsonData text,
    osRedeSociais character varying(50),
    name text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    active boolean DEFAULT true,
    tiposCampanha uuid,
    creator uuid,
    osTypeMidia osTypeMidia,
    osFormato osFormatos DEFAULT '16x9'::osFormatos,
    templateId uuid DEFAULT gen_random_uuid(),
    editaCelebridade boolean,
    editarOferta boolean,
    idCreatomate text,
    quantidadeOfertas text
);

CREATE TABLE IF NOT EXISTS "Tiktok" (
    status osStatus NOT NULL DEFAULT 'Ativo',
    createdDate date DEFAULT CURRENT_DATE,
    empresa uuid,
    creator text,
    identifyId text,
    accessToken text,
    nomeUsuario text,
    contaAds text,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    fotoPerfil text,
    refreshToken text
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
    creator text,
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'America/Sao_Paulo'::text),
    osTypeNotification osTypeNotification,
    previewMidiaId uuid DEFAULT gen_random_uuid(),
    visualizado boolean DEFAULT false
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
    formato osFormatos,
    midiaType osTypeMidia,
    url_midia text,
    thumbnail text,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    id uuid NOT NULL DEFAULT gen_random_uuid()
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
    data_postagem timestamp with time zone DEFAULT now(),
    programado boolean,
    midia_type osTypeMidia,
    formato osFormatos,
    empresa uuid,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    hashtags text,
    creator text,
    url_midia text,
    plataforma text,
    thumbnail text,
    status text DEFAULT 'postado'::text,
    nome_campanha text,
    conteudo text,
    id_social_account text,
    descricao text,
    id_campanha uuid,
    traffic_type text
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
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    pictureUrl text,
    name text,
    email text NOT NULL,
    status user_status DEFAULT 'PENDING'
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
    status user_status,
    updated_at timestamp with time zone,
    user_id uuid,
    email text,
    provider_id text,
    name text,
    pictureUrl text,
    created_at timestamp with time zone,
    id uuid,
    provider text
);

CREATE TABLE IF NOT EXISTS "viewSocialAccounts_ads" (
    name text,
    email text,
    provider_id text,
    ad_title text,
    ad_id uuid,
    ad_created_at timestamp with time zone,
    ad_updated_at timestamp with time zone,
    user_id uuid,
    ad_description text,
    status user_status,
    pictureUrl text,
    provider text,
    social_account_id uuid,
    social_account_created_at timestamp with time zone,
    social_account_updated_at timestamp with time zone
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