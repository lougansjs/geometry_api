#!/usr/bin/env ruby
# frozen_string_literal: true

# ============== IMPORTANT ==============
# Este script cria frames e círculos aleatórios, podendo criar até 450 círculos por frame.
# No entanto, será necessário desabilitar o Rack::Attack para que o script funcione corretamente.
# ============== IMPORTANT ==============

# Script para popular a API Geometry via requisições HTTP
# Uso: ruby scripts/populate_via_api.rb [BASE_URL]

require 'net/http'
require 'json'
require 'uri'

class GeometryApiPopulator
  def initialize(base_url = 'http://localhost:3000')
    @base_url = base_url
    @frames_created = 0
    @circles_created = 0
    @errors = []
  end

  def run
    puts "🌱 Starting Geometry API population via HTTP requests..."
    puts "🎯 Target URL: #{@base_url}"

    # Verificar se a API está rodando
    unless api_available?
      puts "❌ API não está disponível em #{@base_url}"
      puts "💡 Certifique-se de que o servidor Rails está rodando: rails server"
      exit 1
    end

    # Limpar dados existentes
    clear_existing_data

    # Criar frames
    create_frames

    # Criar círculos para cada frame
    create_circles_for_frames

    # Relatório final
    print_final_report
  end

  private

  def api_available?
    uri = URI("#{@base_url}/api/v1/frames")
    response = make_request(:get, uri)
    response.code.to_i == 200
  rescue => e
    false
  end

  def clear_existing_data
    puts "🧹 Clearing existing data..."

    # Buscar todos os frames
    frames = get_all_frames

    # Deletar frames (círculos serão deletados automaticamente por cascade)
    frames.each do |frame|
      delete_frame(frame['id'])
    end

    puts "✅ Existing data cleared"
  end

  def get_all_frames
    uri = URI("#{@base_url}/api/v1/frames")
    response = make_request(:get, uri)

    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      []
    end
  end

  def delete_frame(frame_id)
    uri = URI("#{@base_url}/api/v1/frames/#{frame_id}")
    make_request(:delete, uri)
  end

  def create_frames
    puts "📦 Creating 150 frames via API..."

    50.times do |i|
      attempts = 0
      success = false

      loop do
        attempts += 1
        break if attempts > 50 # Prevent infinite loops

        # Gerar dimensões e posição aleatórias
        width = rand(200.0..800.0).round(2)
        height = rand(200.0..600.0).round(2)
        center_x = rand(100.0..900.0).round(2)
        center_y = rand(100.0..700.0).round(2)

        frame_data = {
          frame: {
            width: width,
            height: height,
            center_x: center_x,
            center_y: center_y
          }
        }

        if create_frame(frame_data)
          @frames_created += 1
          puts "✅ Frame #{i + 1}/150 created: #{width}x#{height} at (#{center_x}, #{center_y})"
          success = true
          break
        end
      end

      unless success
        puts "⚠️  Failed to create frame #{i + 1} after 50 attempts"
        @errors << "Failed to create frame #{i + 1}"
      end
    end

    puts "📊 Created #{@frames_created} frames successfully"
  end

  def create_frame(frame_data)
    uri = URI("#{@base_url}/api/v1/frames")
    response = make_request(:post, uri, frame_data)

    response.code.to_i == 201
  end

  def create_circles_for_frames
    puts "🔵 Creating circles for each frame..."

    frames = get_all_frames
    total_circles = 0

    frames.each_with_index do |frame, frame_index|
      circle_count = rand(12..450)
      created_circles = 0
      attempts = 0
      max_attempts = circle_count * 10

      puts "🔵 Creating #{circle_count} circles for frame #{frame_index + 1}/#{frames.count}..."

      circle_count.times do |circle_index|
        attempts += 1
        break if attempts > max_attempts

        # Gerar círculo aleatório dentro dos limites do frame
        frame_width = frame['width'].to_f
        frame_height = frame['height'].to_f
        frame_center_x = frame['center_x'].to_f
        frame_center_y = frame['center_y'].to_f

        # Calcular limites seguros
        max_radius = [ frame_width, frame_height ].min / 4.0
        diameter = rand(10.0..max_radius * 2).round(2)
        radius = diameter / 2.0

        # Calcular posição segura dentro do frame
        left_edge = frame_center_x - frame_width / 2.0
        right_edge = frame_center_x + frame_width / 2.0
        bottom_edge = frame_center_y - frame_height / 2.0
        top_edge = frame_center_y + frame_height / 2.0

        min_x = left_edge + radius
        max_x = right_edge - radius
        min_y = bottom_edge + radius
        max_y = top_edge - radius

        # Verificar se há espaço válido
        if min_x >= max_x || min_y >= max_y
          puts "⚠️  Frame #{frame_index + 1} too small for circles, skipping remaining"
          break
        end

        center_x = rand(min_x..max_x).round(2)
        center_y = rand(min_y..max_y).round(2)

        circle_data = {
          circle: {
            diameter: diameter,
            center_x: center_x,
            center_y: center_y
          }
        }

        if create_circle(frame['id'], circle_data)
          created_circles += 1
          total_circles += 1
        end
      end

      puts "✅ Frame #{frame_index + 1}: Created #{created_circles}/#{circle_count} circles"
    end

    @circles_created = total_circles
    puts "📊 Created #{@circles_created} circles successfully"
  end

  def create_circle(frame_id, circle_data)
    uri = URI("#{@base_url}/api/v1/frames/#{frame_id}/circles")
    response = make_request(:post, uri, circle_data)

    response.code.to_i == 201
  end

  def make_request(method, uri, data = nil)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 30
    http.open_timeout = 10

    case method
    when :get
      request = Net::HTTP::Get.new(uri)
    when :post
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = data.to_json if data
    when :delete
      request = Net::HTTP::Delete.new(uri)
    end

    response = http.request(request)

    # Log de erros para debug
    if response.code.to_i >= 400
      puts "⚠️  HTTP #{response.code}: #{response.body}" if ENV['DEBUG']
    end

    response
  rescue => e
    puts "❌ Request failed: #{e.message}" if ENV['DEBUG']
    raise e
  end

  def print_final_report
    puts "\n🎉 API Population completed!"
    puts "📊 Final statistics:"
    puts "   - Frames created: #{@frames_created}"
    puts "   - Circles created: #{@circles_created}"
    puts "   - Average circles per frame: #{@frames_created > 0 ? (@circles_created.to_f / @frames_created).round(2) : 0}"

    if @errors.any?
      puts "\n⚠️  Errors encountered:"
      @errors.each { |error| puts "   - #{error}" }
    else
      puts "\n✅ No errors encountered"
    end

    puts "\n🌱 Population finished!"
  end
end

# Executar o script
if __FILE__ == $0
  base_url = ARGV[0] || 'http://localhost:3000'

  begin
    populator = GeometryApiPopulator.new(base_url)
    populator.run
  rescue Interrupt
    puts "\n\n⏹️  Population interrupted by user"
    exit 1
  rescue => e
    puts "\n❌ Fatal error: #{e.message}"
    puts "💡 Make sure the Rails server is running: rails server"
    exit 1
  end
end
