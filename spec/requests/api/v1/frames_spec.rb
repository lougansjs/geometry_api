require 'swagger_helper'

RSpec.describe 'Api::V1::Frames', type: :request do
  let(:frame01) { create(:frame, width: 600, height: 400, center_x: 300, center_y: 200) }
  let(:circle01) { create(:circle, frame: frame01, diameter: 50, center_x: 300, center_y: 300) }

  path '/api/v1/frames' do
    get 'Lista todos os frames' do
      tags 'Frames'
      description 'Retorna uma lista de todos os frames com seus círculos'
      produces 'application/json'

      response '200', 'Lista de frames retornada com sucesso' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   width: { type: :string },
                   height: { type: :string },
                   center_x: { type: :string },
                   center_y: { type: :string },
                   circles: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         diameter: { type: :string },
                         center_x: { type: :string },
                         center_y: { type: :string },
                       }
                     }
                   }
                 },
                 required: %w[id width height center_x center_y circles]
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
        end
      end
    end

    post 'Cria um novo frame' do
      tags 'Frames'
      description 'Cria um novo frame'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :frame, in: :body, schema: {
        type: :object,
        properties: {
          width: { type: :string },
          height: { type: :string },
          center_x: { type: :string },
          center_y: { type: :string },
          circles_attributes: {
            type: :array,
            items: {
              type: :object,
              properties: {
                diameter: { type: :string },
                center_x: { type: :string },
                center_y: { type: :string }
              }
            }
          }
        },
        required: %w[width height center_x center_y]
      }

      response '201', 'Frame criado com sucesso' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 width: { type: :string },
                 height: { type: :string },
                 center_x: { type: :string },
                 center_y: { type: :string }
               },
               required: %w[id width height center_x center_y]

        let(:frame) { { width: 200, height: 200, center_x: 200, center_y: 550 } }
        run_test!
      end

      response '422', 'Dados inválidos' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string }
                 }
               },
               required: %w[errors]

        let(:frame) { { width: -10, height: 100, center_x: 50, center_y: 50 } }
        run_test!
      end
    end
  end

  path '/api/v1/frames/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID do frame'

    get 'Busca um frame por ID com métricas' do
      tags 'Frames'
      description 'Retorna um frame específico com suas métricas calculadas'
      produces 'application/json'

      response '200', 'Frame encontrado com métricas' do
        schema type: :object,
               properties: {
                 frame: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     width: { type: :string },
                     height: { type: :string },
                     center_x: { type: :string },
                     center_y: { type: :string }
                   }
                 },
                 total_circles: { type: :integer },
                 highest_circles: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       center_x: { type: :string },
                       center_y: { type: :string }
                     }
                   }
                 },
                 lowest_circles: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       center_x: { type: :string },
                       center_y: { type: :string }
                     }
                   }
                 },
                 leftmost_circles: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       center_x: { type: :string },
                       center_y: { type: :string }
                     }
                   }
                 },
                 rightmost_circles: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       center_x: { type: :string },
                       center_y: { type: :string }
                     }
                   }
                 }
               },
               required: %w[frame total_circles highest_circles lowest_circles leftmost_circles rightmost_circles]

        let(:id) { frame01.id }
        
        before { circle01 }
        
        run_test!
      end

      response '404', 'Frame não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:id) { 99999 }
        run_test!
      end
    end

    put 'Atualiza um frame' do
      tags 'Frames'
      description 'Atualiza um frame existente'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :frame, in: :body, schema: {
        type: :object,
        properties: {
          width: { type: :string },
          height: { type: :string },
          center_x: { type: :string },
          center_y: { type: :string }
        },
        required: %w[width height center_x center_y]
      }

      response '200', 'Frame atualizado com sucesso' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 width: { type: :string },
                 height: { type: :string },
                 center_x: { type: :string },
                 center_y: { type: :string }
               },
               required: %w[id width height center_x center_y]

        let(:id) { frame01.id }
        let(:frame) { { width: 120, height: 120, center_x: 60, center_y: 60 } }
        run_test!
      end

      response '404', 'Frame não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:id) { 99999 }
        let(:frame) { { width: 120, height: 120, center_x: 60, center_y: 60 } }
        run_test!
      end

      response '422', 'Dados inválidos' do
        schema type: :object,
               properties: {
                 width: {
                   type: :array,
                   items: { type: :string }
                 }
               },
               required: %w[width]

        let(:id) { frame01.id }
        let(:frame) { { width: -10, height: 120, center_x: 60, center_y: 60 } }
        run_test!
      end
    end

    delete 'Remove um frame' do
      tags 'Frames'
      description 'Remove um frame existente (apenas se não tiver círculos associados)'
      produces 'application/json'

      response '204', 'Frame removido com sucesso' do
        let(:id) { frame01.id }
        before { circle01.destroy }
        run_test!
      end

      response '404', 'Frame não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:id) { 99999 }
        run_test!
      end

      response '422', 'Erro ao remover frame (possui círculos associados)' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string }
                 }
               },
               required: %w[errors]

        let(:id) { frame01.id }

        before { allow_any_instance_of(Frame).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed) }

        run_test!
      end
    end
  end

  path '/api/v1/frames/{id}/circles' do
    parameter name: :id, in: :path, type: :integer, description: 'ID do frame'

    post 'Adiciona círculos a um frame' do
      tags 'Frames'
      description 'Adiciona múltiplos círculos a um frame existente'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :circles_data, in: :body, schema: {
        type: :object,
        properties: {
          circles: {
            type: :array,
            items: {
              type: :object,
              properties: {
                diameter: { type: :string },
                center_x: { type: :string },
                center_y: { type: :string }
              },
              required: %w[diameter center_x center_y]
            }
          }
        },
        required: %w[circles]
      }

      response '201', 'Círculos adicionados com sucesso' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   diameter: { type: :string },
                   center_x: { type: :string },
                   center_y: { type: :string },
                 },
                 required: %w[id diameter center_x center_y]
               }

        let(:id) { frame01.id }
        let(:circles_data) do
          {
            circles: [
              { diameter: 10, center_x: 30, center_y: 30 },
              { diameter: 15, center_x: 70, center_y: 70 }
            ]
          }
        end
        run_test!
      end

      response '404', 'Frame não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:id) { 99999 }
        let(:circles_data) do
          {
            circles: [
              { diameter: 10, center_x: 30, center_y: 30 }
            ]
          }
        end
        run_test!
      end

      response '422', 'Dados inválidos' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :object }
                 }
               },
               required: %w[errors]

        let(:id) { frame01.id }
        let(:circles_data) do
          {
            circles: [
              { diameter: -5, center_x: 30, center_y: 30 }
            ]
          }
        end
        run_test!
      end

      response '500', 'Erro interno do servidor' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:id) { frame01.id }
        let(:circles_data) { { circles: [] } }
        run_test!
      end
    end
  end
end