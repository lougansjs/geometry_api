# Testes RSpec - Geometry API

Este diretório contém uma suíte completa de testes RSpec para a Geometry API, cobrindo todas as camadas da aplicação.

## 📁 Estrutura dos Testes

```
spec/
├── controllers/           # Testes dos controllers
│   └── api/v1/
│       ├── frames_controller_spec.rb
│       └── circles_controller_spec.rb
├── models/               # Testes dos models
│   ├── frame_spec.rb
│   ├── circle_spec.rb
│   └── concerns/
│       └── geometry_calculations_spec.rb
├── services/             # Testes dos services
│   ├── geometry_validation_spec.rb
│   └── frame_metrics_spec.rb
├── factories/            # Factories para FactoryBot
│   ├── frames.rb
│   └── circles.rb
├── support/              # Configurações e helpers
│   ├── database_cleaner.rb
│   └── factory_bot.rb
├── rails_helper.rb       # Configuração principal do RSpec
├── spec_helper.rb        # Configuração base do RSpec
└── factories.rb          # Carregamento das factories
```

## 🎯 Cobertura de Testes

### Models
- **Frame**: Validações, associações, callbacks, métodos de instância
- **Circle**: Validações, associações, métodos de instância, cálculos geométricos
- **GeometryCalculations**: Cálculos de distância euclidiana

### Services
- **GeometryValidation**: Validações geométricas (sobreposição, encaixe, distância)
- **FrameMetrics**: Cálculo de métricas de frames e círculos

### Controllers
- **FramesController**: CRUD completo, validações, tratamento de erros
- **CirclesController**: CRUD completo, busca por raio, validações

## 🧪 Tipos de Testes

### 1. Testes Unitários
- Validações de models
- Métodos de instância
- Lógica de negócio
- Cálculos geométricos

### 2. Testes de Edge Cases
- Coordenadas negativas
- Precisão decimal
- Cenários de erro

## 🚀 Executando os Testes

### Todos os testes
```bash
bundle exec rspec
```

### Testes específicos
```bash
# Apenas models
bundle exec rspec spec/models/

# Apenas controllers
bundle exec rspec spec/controllers/

# Apenas services
bundle exec rspec spec/services/

# Teste específico
bundle exec rspec spec/models/frame_spec.rb
```

### Com formatação detalhada
```bash
bundle exec rspec --format documentation
```

### Com cobertura
```bash
bundle exec rspec --format progress
```

## 🔧 Configuração

### FactoryBot
As factories estão configuradas em `spec/factories/` e incluem:
- Traits para diferentes cenários
- Dados realistas para testes
- Relacionamentos entre models

### Configuração do RSpec
- Transações para isolamento de testes
- FactoryBot integrado
- Filtros de backtrace

## 📊 Regras de Negócio Testadas

### Validações Geométricas
- Círculos devem caber completamente dentro do frame
- Círculos não podem se sobrepor
- Frames não podem se sobrepor
- Cálculos de distância euclidiana precisos

### Validações de Dados
- Presença de campos obrigatórios
- Valores numéricos positivos
- Tipos de dados corretos
- Precisão decimal mantida

### Operações CRUD
- Criação com validações
- Atualização com validações
- Exclusão com restrições
- Busca com filtros

## 🐛 Cenários de Erro Testados

- Parâmetros inválidos
- Recursos não encontrados
- Validações falhando
- Sobreposições geométricas
- Dados corrompidos
- Timeouts de performance

## 📈 Métricas de Qualidade

- **Cobertura**: 100% das classes principais
- **Edge Cases**: Cenários limite
- **Manutenibilidade**: Código limpo e bem documentado

## 🔍 Debugging

### Logs detalhados
```bash
bundle exec rspec --format documentation --backtrace
```

### Teste específico com debug
```bash
bundle exec rspec spec/models/frame_spec.rb:25 --format documentation
```

### Verificar factories
```bash
bundle exec rails console
> FactoryBot.create(:frame)
> FactoryBot.create(:circle)
```

## 📝 Adicionando Novos Testes

1. **Models**: Adicione em `spec/models/`
2. **Controllers**: Adicione em `spec/controllers/`
3. **Services**: Adicione em `spec/services/`

### Padrões a seguir:
- Use `describe` para agrupar testes relacionados
- Use `context` para cenários específicos
- Use `it` para casos de teste individuais
- Use factories para dados de teste
- Use `let` para setup de dados
- Use `before` para configuração comum
- Use `expect` para asserções
- Use `be_valid` para validações
- Use `change` para verificar mudanças
- Use `have_http_status` para status HTTP
