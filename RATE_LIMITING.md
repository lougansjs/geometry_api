# Rate Limiting - Geometry API

Este documento descreve as configurações de rate limiting implementadas na API para proteção contra ataques de força bruta.

## Configuração

O rate limiting é implementado usando a gem `rack-attack` e está configurado no arquivo `config/initializers/rack_attack.rb`.

## Limites Configurados

### Rate Limiting Geral
- **100 requests por minuto** por IP para todos os endpoints da API
- **200 requests por minuto** por IP para operações de leitura (GET)

### Rate Limiting para Operações de Escrita
- **20 requests por minuto** por IP para operações POST/PUT/DELETE
- **10 requests por minuto** por IP para criação de frames
- **10 requests por minuto** por IP para criação de círculos
- **5 requests por minuto** por IP para adição de múltiplos círculos

### Proteção Contra Abuso
- **1000 requests em 5 minutos** = bloqueio por 1 hora
- IPs que excedem muito os limites são automaticamente bloqueados

## Whitelist

Os seguintes IPs são automaticamente permitidos (não sofrem rate limiting):

n/a
<!-- - `127.0.0.1` (localhost)
- `::1` (localhost IPv6) -->

## Respostas de Erro

### Status 429 - Too Many Requests

Quando um limite é excedido, a API retorna:

```json
{
  "error": "Rate limit exceeded. Please slow down your requests.",
  "retry_after": 60,
  "limit": 100,
  "remaining": 0,
  "reset_time": 1640995200,
  "limit_type": "throttled"
}
```

### Status 429 - IP Bloqueado

Para IPs bloqueados por abuso:

```json
{
  "error": "Rate limit exceeded. Too many requests from this IP address.",
  "retry_after": 60,
  "limit_type": "blocked"
}
```

## Configuração por Ambiente

### Desenvolvimento
- Rate limiting mais permissivo
- Logs detalhados de tentativas
- Pode ser desabilitado em `development.rb:79`

## Headers de Resposta

A API inclui os seguintes headers informativos:

- `Retry-After`: Tempo em segundos até o próximo reset
- `X-RateLimit-Limit`: Limite máximo de requests
- `X-RateLimit-Remaining`: Requests restantes no período atual
- `X-RateLimit-Reset`: Timestamp do próximo reset

## Monitoramento

### Logs
Em desenvolvimento, todos os eventos de rate limiting são logados:
```
[Rack::Attack] 192.168.1.100 POST /api/v1/frames - api/write/ip
```

### Testar Rate Limiting
```bash
# Teste rápido com curl
for i in {1..105}; do
  curl -w "%{http_code}\n" -o /dev/null -s http://localhost:3000/api/v1/frames
done
```

## Customização

Para ajustar os limites, edite o arquivo `config/initializers/rack_attack.rb`:

```ruby
# Exemplo: Aumentar limite geral para 200 requests/min
Rack::Attack.throttle('api/ip', limit: 200, period: 1.minute) do |req|
  if req.path.start_with?('/api/')
    req.ip
  end
end
```

## Troubleshooting

### Problema: Rate limiting muito restritivo
**Solução**: Ajuste os limites no arquivo de configuração

### Problema: IP legítimo sendo bloqueado
**Solução**: Adicione à whitelist ou ajuste os limites (ou `Rack::Attack.reset!` via rails console)

### Problema: Logs não aparecem
**Solução**: Verifique se `Rails.logger.level` está configurado corretamente
