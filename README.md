# Aurea One - Sistema de Gerenciamento de Mídia

## Sobre o Projeto
Aurea One é um sistema de gerenciamento de mídia que permite a criação, edição e gerenciamento de conteúdo digital para diferentes plataformas de mídia social.

## Estrutura do Banco de Dados
O projeto utiliza Supabase como banco de dados principal, com as seguintes características:
- PostgreSQL 15.8
- Múltiplas extensões (pg_graphql, pg_net, pgcrypto, etc.)
- Sistema completo de gerenciamento de mídia
- Integração com plataformas sociais

### Principais Funcionalidades
- Gerenciamento de campanhas
- Controle de contas de mídia social
- Sistema de renderização de mídia
- Gestão de ofertas e produtos
- Sistema de notificações

## Tecnologias Utilizadas
- Supabase
- PostgreSQL
- Edge Functions
- Integrações com APIs de mídia social

## Estrutura do Projeto
```
.
├── supabase/
│   ├── functions/      # Edge Functions
│   └── migrations/     # Migrações do banco de dados
├── schema.sql          # Esquema completo do banco de dados
└── docs/              # Documentação adicional
```

## Como Iniciar

### Pré-requisitos
- Conta no Supabase
- Node.js instalado
- Supabase CLI

### Configuração
1. Clone o repositório
```bash
git clone [URL_DO_REPOSITÓRIO]
```

2. Configure as variáveis de ambiente
```bash
cp .env.example .env
# Edite o arquivo .env com suas credenciais
```

3. Instale as dependências
```bash
npm install
```

4. Execute as migrações
```bash
supabase db push
```

## Contribuição
Para contribuir com o projeto:
1. Faça um Fork
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença
Este projeto está sob a licença [INSERIR TIPO DE LICENÇA].
