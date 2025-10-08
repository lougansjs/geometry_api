# frozen_string_literal: true

class Rack::Attack
  # Configure cache store for rate limiting
  # Use Redis em produção para melhor performance
  # Rack::Attack.cache.store = Rails.cache

  # Whitelist para IPs confiáveis (desenvolvimento local, etc.)
  # Rack::Attack.safelist('allow-localhost') do |req|
  #   '127.0.0.1' == req.ip || '::1' == req.ip
  # end

  # Rate limiting geral para todos os endpoints da API
  # 100 requests por minuto por IP
  Rack::Attack.throttle("api/ip", limit: 100, period: 1.minute) do |req|
    if req.path.start_with?("/api/")
      req.ip
    end
  end

  # Rate limiting mais restritivo para endpoints de criação (POST)
  # 20 requests por minuto por IP para operações de escrita
  Rack::Attack.throttle("api/write/ip", limit: 20, period: 1.minute) do |req|
    if req.path.start_with?("/api/") && req.post?
      req.ip
    end
  end

  # Rate limiting específico para endpoints sensíveis
  # 10 requests por minuto para criação de frames e círculos
  Rack::Attack.throttle("api/frames/create", limit: 10, period: 1.minute) do |req|
    if req.path.match?(%r{/api/v1/frames$}) && req.post?
      req.ip
    end
  end

  Rack::Attack.throttle("api/circles/create", limit: 10, period: 1.minute) do |req|
    if req.path.match?(%r{/api/v1/circles$}) && req.post?
      req.ip
    end
  end

  # Rate limiting para adição de múltiplos círculos
  # 5 requests por minuto (operação mais pesada)
  Rack::Attack.throttle("api/frames/add_circles", limit: 5, period: 1.minute) do |req|
    if req.path.match?(%r{/api/v1/frames/\d+/circles$}) && req.post?
      req.ip
    end
  end

  # Rate limiting para operações de busca/consulta
  # 200 requests por minuto para GET requests
  Rack::Attack.throttle("api/read/ip", limit: 200, period: 1.minute) do |req|
    if req.path.start_with?("/api/") && req.get?
      req.ip
    end
  end

  # Bloqueio temporário para IPs que excedem muito os limites
  # 1000 requests em 5 minutos = bloqueio por 1 hora
  Rack::Attack.blocklist("block-abusive-ips") do |req|
    Rack::Attack::Allow2Ban.filter(
      "block-abusive-ips-#{req.ip}",
      maxretry: 1000,
      findtime: 5.minutes,
      bantime: 1.hour
    ) do
      req.path.start_with?("/api/")
    end
  end

  # Configuração de resposta para requests bloqueados
  Rack::Attack.blocklisted_response = lambda do |env|
    [
      429, # status
      { "Content-Type" => "application/json" },
      [ {
        error: "Rate limit exceeded. Too many requests from this IP address.",
        retry_after: 60,
        limit_type: "blocked"
      }.to_json ]
    ]
  end

  # Configuração de resposta para requests limitados
  Rack::Attack.throttled_response = lambda do |env|
    match_data = env["rack.attack.match_data"]
    now = match_data[:epoch_time]

    [
      429, # status
      {
        "Content-Type" => "application/json",
        "Retry-After" => match_data[:period].to_s
      },
      [ {
        error: "Rate limit exceeded. Please slow down your requests.",
        retry_after: match_data[:period],
        limit: match_data[:limit],
        remaining: match_data[:limit] - match_data[:count],
        reset_time: now + match_data[:period],
        limit_type: "throttled"
      }.to_json ]
    ]
  end

  # Log de tentativas de rate limiting (apenas em desenvolvimento)
  if Rails.env.development?
    ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
      req = payload[:request]
      Rails.logger.warn "[Rack::Attack] #{req.ip} #{req.request_method} #{req.fullpath} - #{payload[:match_discriminator]}"
    end
  end
end
