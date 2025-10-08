# Geometry API

Uma API RESTful desenvolvida em Ruby on Rails para gerenciamento de geometrias 2D, especificamente frames (retângulos) e círculos. A aplicação permite criar, visualizar e gerenciar frames com círculos associados, incluindo validações geométricas para evitar sobreposições e garantir que os círculos se encaixem dentro dos frames.

## 📋 Sumário

- [Ruby Version](#ruby-version)
- [System Dependencies](#system-dependencies)
- [Configuração](#configuração)
- [Criação do banco de dados](#criação-do-banco-de-dados)
- [Como rodar a suíte de testes](#como-rodar-a-suíte-de-testes)
- [Services](#services-job-queues-cache-servers-search-engines-etc)
- [API Endpoints](#api-endpoints)
- [Documentação API (Swagger)](#documentação-api-swagger)
- [Interface de Visualização](#interface-de-visualização)
- [Desenvolvimento](#desenvolvimento)
- [Rate Limiting](#rate-limiting)
- [Testes RSpec](#testes-rspec)

## Ruby Version

Esta aplicação requer **Ruby 3.3.4** ou superior.

Para verificar sua versão do Ruby:
```bash
ruby --version
```

## System Dependencies

### Dependências Principais
- **Ruby 3.3.4+**
- **PostgreSQL 15+** (banco de dados principal)
- **Bundler** (gerenciador de dependências Ruby)
- **Docker e Docker Compose** (opcional, para desenvolvimento com containers)

## Configuração

### Variáveis de Ambiente

A aplicação utiliza as seguintes variáveis de ambiente para configuração do banco de dados:

```bash
# Configurações do Banco de Dados
DATABASE_HOST=localhost          # Host do PostgreSQL (padrão: localhost)
DATABASE_PORT=5432              # Porta do PostgreSQL (padrão: 5432)
DATABASE_USERNAME=postgres      # Usuário do banco (padrão: postgres)
DATABASE_PASSWORD=postgres      # Senha do banco (padrão: postgres)

# Configurações da Aplicação
RAILS_ENV=development           # Ambiente Rails
RAILS_MAX_THREADS=5            # Número máximo de threads
```

### Configurações Específicas

#### CORS (Cross-Origin Resource Sharing)
A aplicação está configurada para aceitar requisições de qualquer origem (`*`) em desenvolvimento. Para produção, configure adequadamente no arquivo `config/initializers/cors.rb`.

#### Rate Limiting
A aplicação implementa rate limiting usando Rack::Attack com os seguintes limites:
- **API geral**: 100 requests/minuto por IP
- **Operações de escrita (POST)**: 20 requests/minuto por IP
- **Criação de frames/círculos**: 10 requests/minuto por IP
- **Adição de múltiplos círculos**: 5 requests/minuto por IP
- **Operações de leitura (GET)**: 200 requests/minuto por IP

## Criação do banco de dados

### Usando Docker Compose (Recomendado)
```bash
# Iniciar os serviços (PostgreSQL + aplicação)
docker-compose up -d

# A aplicação criará automaticamente o banco de dados
```

### Estrutura do Banco de Dados

A aplicação possui duas tabelas principais:

#### Frames (Retângulos)
- `id`: Identificador único
- `width`: Largura do frame
- `height`: Altura do frame
- `center_x`: Coordenada X do centro
- `center_y`: Coordenada Y do centro
- `created_at`, `updated_at`: Timestamps

#### Circles (Círculos)
- `id`: Identificador único
- `diameter`: Diâmetro do círculo
- `center_x`: Coordenada X do centro
- `center_y`: Coordenada Y do centro
- `frame_id`: Referência ao frame pai
- `created_at`, `updated_at`: Timestamps

### Comandos de Inicialização
```bash
# Criar e migrar banco de dados
bundle exec rails db:create
bundle exec rails db:schema:load
bundle exec rails db:migrate

# Há um arquivo seed para popular com dados de exemplo,
# no entanto, é necessário desativar o Rack-Attack em development.rb
bundle exec rails db:seed

# Para ambiente de teste
RAILS_ENV=test bundle exec rails db:create
RAILS_ENV=test bundle exec rails db:migrate
```

## Como rodar a suíte de testes

A aplicação utiliza **RSpec** como framework de testes.

### Executar Todos os Testes
```bash
# Executar toda a suíte de testes
bundle exec rspec

# Executar com formatação detalhada
bundle exec rspec --format documentation

# Executar testes específicos
bundle exec rspec spec/models/
bundle exec rspec spec/controllers/
bundle exec rspec spec/services/
```

### Estrutura de Testes
- **Modelos**: `spec/models/` - Testes de validações e métodos dos modelos
- **Controllers**: `spec/controllers/` - Testes dos endpoints da API
- **Services**: `spec/services/` - Testes da lógica de negócio
- **Factories**: `spec/factories/` - Dados de teste usando FactoryBot

### Dependências de Teste
- **RSpec Rails**: Framework de testes
- **FactoryBot**: Geração de dados de teste
- **Database Cleaner**: Limpeza do banco entre testes
- **Shoulda Matchers**: Matchers para testes de validação

## Services

### Serviços de Aplicação

#### GeometryValidation
Serviço responsável por validações geométricas:
- Verificar se círculos se encaixam dentro de frames
- Detectar sobreposições entre círculos
- Detectar sobreposições entre frames
- Validar posicionamento dentro de raios específicos

#### FrameMetrics
Serviço para cálculo de métricas de frames:
- Contagem total de círculos
- Identificação de círculos extresmos (mais alto, baixo, esquerda, direita)
- Análise de distribuição espacial

### Serviços Externos

#### PostgreSQL
- Banco de dados principal
- Suporte a múltiplos bancos (desenvolvimento, teste, produção)
- Configuração separada para cache, queue e cable em produção

#### Puma
- Servidor web de produção
- Configurado para múltiplas threads
- Otimizado para APIs

## API Endpoints

### Frames
- `GET /api/v1/frames` - Listar todos os frames
- `POST /api/v1/frames` - Criar novo frame
- `GET /api/v1/frames/:id` - Visualizar frame específico
- `PUT/PATCH /api/v1/frames/:id` - Atualizar frame
- `DELETE /api/v1/frames/:id` - Deletar frame
- `POST /api/v1/frames/:id/circles` - Adicionar círculos ao frame

### Circles
- `GET /api/v1/circles` - Listar todos os círculos
- `GET /api/v1/circles/:id` - Visualizar círculo específico
- `PUT/PATCH /api/v1/circles/:id` - Atualizar círculo
- `DELETE /api/v1/circles/:id` - Deletar círculo

## Documentação API (Swagger)

A API possui documentação interativa completa usando Swagger/OpenAPI. A documentação é gerada automaticamente a partir dos testes RSpec e inclui exemplos de requisições e respostas.

### Acesso à Documentação

Abra seu navegador e acesse:
- **Interface Swagger UI**: http://localhost:3000/api-docs
- **Especificação YAML**: http://localhost:3000/api-docs/v1/swagger.yaml

## Interface de Visualização

Adicionalmente, foi gerada na aplicação uma interface web interativa para visualização das formas geométricas (frames e círculos) armazenadas no banco de dados.

> **⚠️ Disclaimer**: Esta interface foi desenvolvida com assistência de IA para demonstração e visualização dos dados da API.

### Acesso à Interface

A interface está disponível na rota raiz da aplicação:

```bash
# Acessar via navegador
http://localhost:3000
```

### Estrutura da Interface

```
app/views/pages/
└── index.html.erb          # Interface principal de visualização
```

A interface consome os endpoints da API para:
- Buscar frames e círculos (`GET /api/v1/frames`)
- Exibir informações detalhadas de cada forma
- Renderizar visualmente as relações entre frames e círculos

## Desenvolvimento

### Executar em Desenvolvimento (sem docker)
```bash
# Instalar dependências
bundle install

# Configurar banco de dados
bundle exec rails db:create db:migrate

# Iniciar servidor
bundle exec rails server
```

### Usando Docker
```bash
# Construir e executar com Docker Compose
docker-compose up --build
```

### Scripts Úteis
```bash
# Executar análise de segurança
bundle exec brakeman

# Executar linter
bundle exec rubocop

# Popula o banco de dados com Frames e Círculos aleatórios (alternativa para db:seed)
ruby scripts/populate_via_api.rb

# Executar setup completo
bin/setup
```

## Documentação Adicional

### Rate Limiting
Para informações detalhadas sobre as configurações de rate limiting da API, consulte:
**[📄 RATE_LIMITING.md](./RATE_LIMITING.md)**

### RSpec
Para informações detalhadas sobre os testes de API com RSpec, consulte:
**[📄 RSPEC.md](spec/README.md)**

----

### Troubleshooting

#### Problema: Rate limiting muito restritivo
**Solução**: Ajuste os limites no arquivo de configuração

#### Problema: IP legítimo sendo bloqueado
**Solução**: Adicione à whitelist ou ajuste os limites (ou `Rack::Attack.reset!` via rails console)