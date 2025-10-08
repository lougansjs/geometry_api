RSpec.configure do |config|
  # Configurações específicas para diferentes tipos de teste
  config.before(:each, type: :controller) do
    @request.env['HTTP_ACCEPT'] = 'application/json'
  end

  config.before(:each, type: :request) do
    # Para testes de request, os headers são configurados via parâmetros do request
    # Não há @request disponível neste tipo de teste
  end

  # Configurações para testes de performance
  config.before(:each, type: :performance) do
    # Desabilitar logging para testes de performance
    Rails.logger.level = Logger::WARN
  end

  # Configurações para testes de integração
  config.before(:each, type: :integration) do
    # Limpar cache entre testes de integração
    Rails.cache.clear
  end

  # Configurações para testes de models
  config.before(:each, type: :model) do
    # Garantir que o banco está limpo
    DatabaseCleaner.start
  end

  config.after(:each, type: :model) do
    DatabaseCleaner.clean
  end

  # Configurações globais
  config.before(:suite) do
    # Configurar DatabaseCleaner
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # FactoryBot é configurado automaticamente
end
