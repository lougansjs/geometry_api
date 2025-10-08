namespace :swagger do
  desc "Gera a documentação Swagger"
  task generate: :environment do
    puts "Gerando documentação Swagger..."
    Rake::Task['rswag:specs:swaggerize'].invoke
    puts "Documentação Swagger gerada com sucesso!"
    puts "Acesse: http://localhost:3000/api-docs"
  end

  desc "Limpa e regenera a documentação Swagger"
  task clean_generate: :environment do
    puts "Limpando documentação Swagger existente..."
    FileUtils.rm_rf(Rails.root.join('swagger'))
    puts "Gerando nova documentação Swagger..."
    Rake::Task['rswag:specs:swaggerize'].invoke
    puts "Documentação Swagger regenerada com sucesso!"
    puts "Acesse: http://localhost:3000/api-docs"
  end

  desc "Executa apenas os specs de documentação"
  task test_docs: :environment do
    puts "Executando specs de documentação..."
    system("bundle exec rspec spec/requests/ --format documentation")
  end
end