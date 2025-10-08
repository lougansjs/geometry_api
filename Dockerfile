# Use a imagem oficial do Ruby
FROM ruby:3.3.0-alpine

# Instalar dependências do sistema
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    git

# Definir diretório de trabalho
WORKDIR /app

# Copiar Gemfile e Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Instalar gems
RUN bundle install --with development test

# Copiar código da aplicação
COPY . .

# Criar diretórios necessários
RUN mkdir -p tmp/pids log storage

# Expor porta
EXPOSE 3000

# Comando para iniciar a aplicação
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
