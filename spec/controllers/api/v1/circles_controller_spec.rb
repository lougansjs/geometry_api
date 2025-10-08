require 'rails_helper'

RSpec.describe 'Circles API', type: :request do
  let(:frame) { create(:frame, width: 600.0, height: 400.0, center_x: 300.0, center_y: 200.0) }
  let(:circle) { create(:circle, frame: frame, center_x: 120.0, center_y: 160.0, diameter: 30.0) }

  describe 'GET /api/v1/circles' do
    let!(:circle_1) { create(:circle, frame: frame, center_x: 110.0, center_y: 110.0, diameter: 20.0) }
    let!(:circle_2) { create(:circle, frame: frame, center_x: 200.0, center_y: 200.0, diameter: 20.0) }

    context 'with valid search parameters' do
      let(:search_params) do
        {
          center_x: 145.0,
          center_y: 140.0,
          radius: 65.0
        }
      end

      it 'filters circles within radius' do
        get '/api/v1/circles', params: search_params
        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(1)
      end

      it 'filters by frame_id when provided' do
        get '/api/v1/circles', params: search_params.merge(frame_id: frame.id)
        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(1)
      end
    end

    context 'with invalid search parameters' do
      it 'returns bad request for missing parameters' do
        get '/api/v1/circles', params: { center_x: 100.0 }
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to include('Missing required search parameters')
      end

      it 'returns bad request for invalid center_x' do
        get '/api/v1/circles', params: { center_x: 'invalid', center_y: 100.0, radius: 50.0 }
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to include('center_x must be a valid number')
      end

      it 'returns bad request for invalid center_y' do
        get '/api/v1/circles', params: { center_x: 100.0, center_y: 'invalid', radius: 50.0 }
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to include('center_y must be a valid number')
      end

      it 'returns bad request for invalid radius' do
        get '/api/v1/circles', params: { center_x: 100.0, center_y: 100.0, radius: -10.0 }
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to include('radius must be a positive number')
      end

      it 'returns bad request for zero radius' do
        get '/api/v1/circles', params: { center_x: 100.0, center_y: 100.0, radius: 0.0 }
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to include('radius must be a positive number')
      end
    end

    context 'when no circles found' do
      it 'returns not found' do
        get '/api/v1/circles', params: { center_x: 1000.0, center_y: 1000.0, radius: 10.0 }
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('No circles found')
      end
    end

    context 'with edge case parameters' do
      it 'handles zero coordinates' do
        get '/api/v1/circles', params: { center_x: 0.0, center_y: 0.0, radius: 200.0 }
        expect(response).to have_http_status(:ok)
      end

      it 'handles decimal coordinates' do
        get '/api/v1/circles', params: { center_x: 210.15, center_y: 215.202, radius: 50.0 }
        expect(response).to have_http_status(:ok)
      end

      it 'handles very small radius' do
        get '/api/v1/circles', params: { center_x: 100.0, center_y: 100.0, radius: 0.001 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /api/v1/circles/:id' do
    context 'when circle exists' do
      it 'returns the circle' do
        get "/api/v1/circles/#{circle.id}"
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(circle.id)
      end
    end

    context 'when circle does not exist' do
      it 'returns not found' do
        get '/api/v1/circles/99999'
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Circle not found')
      end
    end
  end

  describe 'PATCH /api/v1/circles/:id' do
    context 'with valid parameters' do
      let(:new_attributes) { { center_x: 150.0, center_y: 200.0 } }

      it 'updates the circle' do
        patch "/api/v1/circles/#{circle.id}", params: { circle: new_attributes }
        circle.reload
        expect(circle.center_x).to eq(150.0)
        expect(circle.center_y).to eq(200.0)
      end

      it 'returns ok status' do
        patch "/api/v1/circles/#{circle.id}", params: { circle: new_attributes }
        expect(response).to have_http_status(:ok)
      end

      it 'returns the updated circle' do
        patch "/api/v1/circles/#{circle.id}", params: { circle: new_attributes }
        json_response = JSON.parse(response.body)
        expect(json_response['center_x']).to eq("150.0")
      end
    end

    context 'with invalid parameters' do
      it 'does not update the circle' do
        original_center_x = circle.center_x
        patch "/api/v1/circles/#{circle.id}", params: { circle: { center_x: nil } }
        circle.reload
        expect(circle.center_x).to eq(original_center_x)
      end

      it 'returns unprocessable entity status' do
        patch "/api/v1/circles/#{circle.id}", params: { circle: { center_x: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when circle does not exist' do
      it 'returns not found' do
        patch '/api/v1/circles/99999', params: { circle: { center_x: 150.0 } }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with overlapping position' do
      let!(:other_circle) { create(:circle, frame: frame, center_x: 200.0, center_y: 200.0, diameter: 50.0) }

      it 'prevents update to overlapping position' do
        patch "/api/v1/circles/#{circle.id}", params: { circle: { center_x: 200.0, center_y: 200.0 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /api/v1/circles/:id' do
    let!(:circle) { create(:circle, frame: frame, center_x: 240.0, center_y: 320.0, diameter: 55.0) }

    context 'when circle exists' do
      it 'destroys the circle' do
        expect {
          delete "/api/v1/circles/#{circle.id}"
        }.to change(Circle, :count).by(-1)
      end

      it 'returns no content status' do
        delete "/api/v1/circles/#{circle.id}"
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when circle does not exist' do
      it 'returns not found' do
        delete '/api/v1/circles/99999'
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when circle cannot be destroyed' do
      before do
        allow_any_instance_of(Circle).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)
      end

      it 'returns unprocessable entity status' do
        delete "/api/v1/circles/#{circle.id}"
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
