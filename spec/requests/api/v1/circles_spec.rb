require 'swagger_helper'

RSpec.describe 'Api::V1::Circles', type: :request do
  let!(:frame) { create(:frame, width: 600, height: 400, center_x: 300, center_y: 200) }
  let!(:circle01) { create(:circle, frame: frame, center_x: 300, center_y: 300, diameter: 50) }

  path '/api/v1/circles' do
    get 'Lista todos os círculos' do
      tags 'Circles'
      description 'Retorna uma lista de círculos, com opção de filtrar por frame_id e buscar por raio'
      produces 'application/json'

      parameter name: :frame_id, in: :query, type: :integer, required: false, description: 'ID do frame para filtrar círculos'
      parameter name: :center_x, in: :query, type: :number, required: false, description: 'Coordenada X do centro para busca por raio'
      parameter name: :center_y, in: :query, type: :number, required: false, description: 'Coordenada Y do centro para busca por raio'
      parameter name: :radius, in: :query, type: :number, required: false, description: 'Raio para busca de círculos'

      response '200', 'Lista de círculos retornada com sucesso' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   diameter: { type: :string },
                   center_x: { type: :string },
                   center_y: { type: :string }
                 },
                 required: %w[id diameter center_x center_y]
               }

        let(:frame_id) { frame.id }
        let(:center_x) { 300 }
        let(:center_y) { 350 }
        let(:radius) { 100 }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
        end
      end

      response '400', 'Parâmetros inválidos' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:center_x) { 'invalid' }
        let(:center_y) { 10 }
        let(:radius) { 5 }
        run_test!
      end

      response '404', 'Nenhum círculo encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:center_x) { 1000 }
        let(:center_y) { 1000 }
        let(:radius) { 1 }
        run_test!
      end
    end
  end

  path '/api/v1/circles/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID do círculo'

    get 'Busca um círculo por ID' do
      tags 'Circles'
      description 'Retorna um círculo específico pelo seu ID'
      produces 'application/json'

      response '200', 'Círculo encontrado' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 diameter: { type: :string },
                 center_x: { type: :string },
                 center_y: { type: :string }
               },
               required: %w[id diameter center_x center_y]

        let(:id) { circle01.id }
        run_test!
      end

      response '404', 'Círculo não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:id) { 99999 }
        run_test!
      end
    end

    put 'Atualiza um círculo' do
      tags 'Circles'
      description 'Atualiza um círculo existente'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :circle, in: :body, schema: {
        type: :object,
        properties: {
          center_x: { type: :string },
          center_y: { type: :string }
        },
        required: %w[center_x center_y]
      }

      response '200', 'Círculo atualizado com sucesso' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 diameter: { type: :string },
                 center_x: { type: :string },
                 center_y: { type: :string }
               },
               required: %w[id diameter center_x center_y]

        let(:id) { circle01.id }
        let(:circle) { { center_x: 60, center_y: 60 } }
        run_test!
      end

      response '404', 'Círculo não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:id) { 99999 }
        let(:circle) { { center_x: 60, center_y: 60 } }
        run_test!
      end

      response '422', 'Dados inválidos' do
        schema type: :array,
               items: { type: :string }

        let(:id) { circle01.id }
        let(:circle) { { center_x: -10, center_y: 60 } }
        run_test!
      end
    end

    delete 'Remove um círculo' do
      tags 'Circles'
      description 'Remove um círculo existente'
      produces 'application/json'

      response '204', 'Círculo removido com sucesso' do
        let(:id) { circle01.id }
        run_test!
      end

      response '404', 'Círculo não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:id) { 99999 }
        run_test!
      end

      response '422', 'Erro ao remover círculo' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string }
                 }
               },
               required: %w[errors]

        let(:id) { circle01.id }

        before do
          allow_any_instance_of(Circle).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)
          allow_any_instance_of(Circle).to receive(:errors).and_return(
            double('errors', full_messages: [ 'Cannot delete circle due to business rules' ])
          )
        end

        run_test!
      end
    end
  end
end
