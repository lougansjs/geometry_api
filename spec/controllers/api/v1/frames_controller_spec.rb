require 'rails_helper'

RSpec.describe 'Frames API', type: :request do
  let(:valid_attributes) do
    {
      width: 200.0,
      height: 300.0,
      center_x: 100.0,
      center_y: 150.0
    }
  end

  let(:invalid_attributes) do
    {
      width: -100.0,
      height: 0.0,
      center_x: nil,
      center_y: nil
    }
  end

  let(:valid_circles_attributes) do
    [
      { diameter: 30.0, center_x: 120.0, center_y: 160.0 },
      { diameter: 25.0, center_x: 80.0, center_y: 140.0 }
    ]
  end

  let(:invalid_circles_attributes) do
    [
      { diameter: -10.0, center_x: 120.0, center_y: 160.0 },
      { diameter: 30.0, center_x: nil, center_y: 160.0 }
    ]
  end

  describe 'GET /api/v1/frames' do
    let!(:frame_1) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 200.0) }
    let!(:frame_2) { create(:frame, center_x: 300.0, center_y: 300.0, width: 200.0, height: 200.0) }
    let!(:frame_3) { create(:frame, center_x: 500.0, center_y: 500.0, width: 200.0, height: 200.0) }

    it 'returns all frames' do
      get '/api/v1/frames'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(3)
    end

    it 'returns frames as JSON' do
      get '/api/v1/frames'
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'GET /api/v1/frames/:id' do
    let(:frame) { create(:frame, width: 200.0, height: 200.0, center_x: 100.0, center_y: 100.0) }
    let!(:circle_1) { create(:circle, frame: frame, center_x: 55.0, center_y: 48.0, diameter: 20.0) }
    let!(:circle_2) { create(:circle, frame: frame, center_x: 97.0, center_y: 34.0, diameter: 20.0) }
    let!(:circle_3) { create(:circle, frame: frame, center_x: 80.0, center_y: 78.0, diameter: 20.0) }

    context 'when frame exists' do
      it 'returns frame metrics' do
        get "/api/v1/frames/#{frame.id}"
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('frame')
        expect(json_response).to have_key('total_circles')
      end

      it 'uses FrameMetricsSerializer' do
        expect_any_instance_of(FrameMetricsSerializer).to receive(:as_json).and_return({})
        get "/api/v1/frames/#{frame.id}"
      end
    end

    context 'when frame does not exist' do
      it 'returns not found' do
        get '/api/v1/frames/99999'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Frame not found')
      end
    end
  end

  describe 'POST /api/v1/frames' do
    context 'with valid parameters' do
      it 'creates a new frame' do
        expect {
          post '/api/v1/frames', params: { frame: valid_attributes }
        }.to change(Frame, :count).by(1)
      end

      it 'returns created status' do
        post '/api/v1/frames', params: { frame: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it 'returns the created frame' do
        post '/api/v1/frames', params: { frame: valid_attributes }
        json_response = JSON.parse(response.body)
        expect(json_response['width']).to eq("200.0")
        expect(json_response['height']).to eq("300.0")
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new frame' do
        expect {
          post '/api/v1/frames', params: { frame: invalid_attributes }
        }.not_to change(Frame, :count)
      end

      it 'returns unprocessable entity status' do
        post '/api/v1/frames', params: { frame: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        post '/api/v1/frames', params: { frame: invalid_attributes }
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
      end
    end

    context 'with overlapping frames' do
      let!(:existing_frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 200.0) }
      let(:overlapping_attributes) { valid_attributes.merge(center_x: 150.0, center_y: 150.0) }

      it 'prevents creation of overlapping frame' do
        post '/api/v1/frames', params: { frame: overlapping_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with nested circles attributes' do
      let(:frame_with_circles_attributes) do
        valid_attributes.merge(
          circles_attributes: valid_circles_attributes
        )
      end

      it 'creates frame with circles' do
        expect {
          post '/api/v1/frames', params: { frame: frame_with_circles_attributes }
        }.to change(Frame, :count).by(1)
          .and change(Circle, :count).by(2)
      end
    end
  end

  describe 'PATCH /api/v1/frames/:id' do
    let(:frame) { create(:frame, width: 250.0, height: 250.0, center_x: 100.0, center_y: 100.0) }

    context 'with valid parameters' do
      let(:new_attributes) { { width: 300.0, height: 350.0 } }

      it 'updates the frame' do
        patch "/api/v1/frames/#{frame.id}", params: { frame: new_attributes }
        frame.reload
        expect(frame.width).to eq(300.0)
        expect(frame.height).to eq(350.0)
      end

      it 'returns ok status' do
        patch "/api/v1/frames/#{frame.id}", params: { frame: new_attributes }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters' do
      it 'does not update the frame' do
        original_width = frame.width
        patch "/api/v1/frames/#{frame.id}", params: { frame: invalid_attributes }
        frame.reload
        expect(frame.width).to eq(original_width)
      end

      it 'returns unprocessable entity status' do
        patch "/api/v1/frames/#{frame.id}", params: { frame: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when frame does not exist' do
      it 'returns not found' do
        patch '/api/v1/frames/99999', params: { frame: valid_attributes }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/frames/:id' do
    let!(:frame) { create(:frame, width: 250.0, height: 250.0, center_x: 100.0, center_y: 100.0) }

    context 'when frame has no circles' do
      it 'destroys the frame' do
        expect {
          delete "/api/v1/frames/#{frame.id}"
        }.to change(Frame, :count).by(-1)
      end

      it 'returns no content status' do
        delete "/api/v1/frames/#{frame.id}"
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when frame has circles' do
      before { create(:circle, frame: frame, center_x: 50.0, center_y: 50.0, diameter: 20.0) }

      it 'does not destroy the frame' do
        expect {
          delete "/api/v1/frames/#{frame.id}"
        }.not_to change(Frame, :count)
      end

      it 'returns unprocessable entity status' do
        delete "/api/v1/frames/#{frame.id}"
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message' do
        delete "/api/v1/frames/#{frame.id}"
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Cannot delete frame with associated circles')
      end
    end

    context 'when frame does not exist' do
      it 'returns not found' do
        delete '/api/v1/frames/99999'
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/frames/:id/circles' do
    let(:frame) { create(:frame, width: 600.0, height: 400.0, center_x: 300.0, center_y: 200.0) }

    context 'with valid circles' do
      it 'creates circles' do
        expect {
          post "/api/v1/frames/#{frame.id}/circles", params: { circles: valid_circles_attributes }
        }.to change(Circle, :count).by(2)
      end

      it 'returns created status' do
        post "/api/v1/frames/#{frame.id}/circles", params: { circles: valid_circles_attributes }
        expect(response).to have_http_status(:created)
      end

      it 'returns created circles' do
        post "/api/v1/frames/#{frame.id}/circles", params: { circles: valid_circles_attributes }
        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(2)
      end
    end

    context 'with invalid circles' do
      it 'does not create any circles' do
        expect {
          post "/api/v1/frames/#{frame.id}/circles", params: { circles: invalid_circles_attributes }
        }.not_to change(Circle, :count)
      end

      it 'returns unprocessable entity status' do
        post "/api/v1/frames/#{frame.id}/circles", params: { circles: invalid_circles_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns formatted errors by circle' do
        post "/api/v1/frames/#{frame.id}/circles", params: { circles: invalid_circles_attributes }
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
        expect(json_response['errors']).to be_an(Array)
      end
    end

    context 'with mixed valid and invalid circles' do
      let(:mixed_circles_attributes) do
        [
          { diameter: 30.0, center_x: 120.0, center_y: 160.0 }, # valid
          { diameter: -10.0, center_x: 80.0, center_y: 140.0 }  # invalid
        ]
      end

      it 'creates only valid circles' do
        expect {
          post "/api/v1/frames/#{frame.id}/circles", params: { circles: mixed_circles_attributes }
        }.to change(Circle, :count).by(1)
      end

      it 'returns unprocessable entity status' do
        post "/api/v1/frames/#{frame.id}/circles", params: { circles: mixed_circles_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when frame does not exist' do
      it 'returns not found' do
        post '/api/v1/frames/99999/circles', params: { circles: valid_circles_attributes }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with overlapping circles' do
      let!(:existing_circle) { create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0) }
      let(:overlapping_circles) do
        [
          { diameter: 30.0, center_x: 120.0, center_y: 100.0 } # overlaps with existing
        ]
      end

      it 'prevents creation of overlapping circles' do
        expect {
          post "/api/v1/frames/#{frame.id}/circles", params: { circles: overlapping_circles }
        }.not_to change(Circle, :count)
      end
    end
  end
end
