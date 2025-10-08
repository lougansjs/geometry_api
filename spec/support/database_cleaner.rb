RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before(:each, type: :performance) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each, type: :performance) do
    DatabaseCleaner.clean
  end
end
