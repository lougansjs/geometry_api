require 'rails_helper'

RSpec.describe Frame, type: :model do
  describe 'associations' do
    it { should have_many(:circles).dependent(:restrict_with_exception) }
  end

  describe 'validations' do
    describe 'presence validations' do
      it { should validate_presence_of(:width) }
      it { should validate_presence_of(:height) }
      it { should validate_presence_of(:center_x) }
      it { should validate_presence_of(:center_y) }
    end

    describe 'numericality validations' do
      it { should validate_numericality_of(:width).is_greater_than(0) }
      it { should validate_numericality_of(:height).is_greater_than(0) }
    end

    describe 'custom validations' do
      describe 'must_not_touch_other_frames' do
        let!(:existing_frame) { create(:frame, center_x: 500.0, center_y: 500.0, width: 100.0, height: 100.0) }

        context 'when frames do not overlap' do
          let(:frame) { build(:frame, center_x: 400.0, center_y: 400.0, width: 100.0, height: 100.0) }

          it 'is valid' do
            expect(frame).to be_valid
          end
        end

        context 'when frames overlap' do
          let(:frame) { build(:frame, center_x: 450.0, center_y: 450.0, width: 100.0, height: 100.0) }

          it 'is invalid' do
            expect(frame).not_to be_valid
            expect(frame.errors[:base]).to include('Frame cannot overlap with other frames')
          end
        end

        context 'when updating existing frame' do
          let!(:frame) { create(:frame, center_x: 400.0, center_y: 400.0, width: 100.0, height: 100.0) }

          it 'allows updating without overlap check against self' do
            frame.update!(width: 150.0)
            expect(frame).to be_valid
          end
        end
      end
    end
  end

  describe 'callbacks' do
    describe 'before_destroy' do
      let(:frame) { create(:frame) }

      context 'when frame has no circles' do
        it 'allows destruction' do
          expect { frame.destroy! }.not_to raise_error
        end
      end

      context 'when frame has circles' do
        before { create(:circle, frame: frame) }

        it 'prevents destruction' do
          expect { frame.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
        end

        it 'adds error message' do
          frame.destroy
          expect(frame.errors[:base]).to include('Cannot delete frame with associated circles')
        end
      end
    end
  end

  describe 'nested attributes' do
    it { should accept_nested_attributes_for(:circles) }
  end

  describe 'instance methods' do
    let(:frame) { create(:frame, width: 200.0, height: 300.0, center_x: 100.0, center_y: 150.0) }

    describe '#left_edge' do
      it 'returns correct left edge' do
        expect(frame.left_edge).to eq(0.0)
      end
    end

    describe '#right_edge' do
      it 'returns correct right edge' do
        expect(frame.right_edge).to eq(200.0)
      end
    end

    describe '#top_edge' do
      it 'returns correct top edge' do
        expect(frame.top_edge).to eq(300.0)
      end
    end

    describe '#bottom_edge' do
      it 'returns correct bottom edge' do
        expect(frame.bottom_edge).to eq(0.0)
      end
    end

    describe '#bounds' do
      it 'returns correct bounds hash' do
        expected_bounds = {
          min_x: 0.0,
          max_x: 200.0,
          min_y: 0.0,
          max_y: 300.0
        }
        expect(frame.bounds).to eq(expected_bounds)
      end
    end
  end

  describe 'edge cases and business rules' do
    describe 'frame positioning' do
      context 'when frame has decimal dimensions' do
        let(:frame) { build(:frame, width: 199.99, height: 299.99, center_x: 100.0, center_y: 150.0) }

        it 'handles decimal calculations correctly' do
          expect(frame.left_edge).to be_within(0.01).of(0.005)
          expect(frame.right_edge).to be_within(0.01).of(199.995)
        end
      end
    end

    describe 'frame overlap scenarios' do
      let!(:frame1) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 200.0) }

      context 'when frames touch but do not overlap' do
        let(:frame2) { build(:frame, center_x: 300.0, center_y: 100.0, width: 200.0, height: 200.0) }

        it 'allows creation' do
          expect(frame2).to be_valid
        end
      end

      context 'when frames partially overlap' do
        let(:frame2) { build(:frame, center_x: 200.0, center_y: 100.0, width: 200.0, height: 200.0) }

        it 'prevents creation' do
          expect(frame2).not_to be_valid
        end
      end

      context 'when frames completely overlap' do
        let(:frame2) { build(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 200.0) }

        it 'prevents creation' do
          expect(frame2).not_to be_valid
        end
      end
    end
  end
end
