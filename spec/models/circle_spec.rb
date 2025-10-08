require 'rails_helper'

RSpec.describe Circle, type: :model do
  describe 'associations' do
    it { should belong_to(:frame) }
  end

  describe 'validations' do
    describe 'presence validations' do
      it { should validate_presence_of(:diameter) }
      it { should validate_presence_of(:center_x) }
      it { should validate_presence_of(:center_y) }
    end

    describe 'numericality validations' do
      it { should validate_numericality_of(:diameter).is_greater_than(0) }
    end

    describe 'custom validations' do
      let(:frame) { create(:frame, width: 200.0, height: 200.0, center_x: 100.0, center_y: 100.0) }

      describe 'must_fit_inside_frame' do
        context 'when circle fits completely inside frame' do
          let(:circle) { build(:circle, frame: frame, diameter: 50.0, center_x: 100.0, center_y: 100.0) }

          it 'is valid' do
            expect(circle).to be_valid
          end
        end

        context 'when circle extends beyond frame edges' do
          let(:circle) { build(:circle, frame: frame, diameter: 300.0, center_x: 100.0, center_y: 100.0) }

          it 'is invalid' do
            expect(circle).not_to be_valid
            expect(circle.errors[:base]).to include('Circle must fit completely inside the frame')
          end
        end

        context 'when circle touches frame edge' do
          let(:circle) { build(:circle, frame: frame, diameter: 200.0, center_x: 100.0, center_y: 100.0) }

          it 'is valid (touching is allowed)' do
            expect(circle).to be_valid
          end
        end

        context 'when circle is positioned at frame corner' do
          let(:circle) { build(:circle, frame: frame, diameter: 100.0, center_x: 50.0, center_y: 50.0) }

          it 'is valid' do
            expect(circle).to be_valid
          end
        end
      end

      describe 'must_not_touch_other_circles' do
        let!(:existing_circle) { create(:circle, frame: frame, diameter: 50.0, center_x: 100.0, center_y: 100.0) }

        context 'when circles do not overlap' do
          let(:circle) { build(:circle, frame: frame, diameter: 30.0, center_x: 150.0, center_y: 150.0) }

          it 'is valid' do
            expect(circle).to be_valid
          end
        end

        context 'when circles overlap' do
          let(:circle) { build(:circle, frame: frame, diameter: 50.0, center_x: 120.0, center_y: 100.0) }

          it 'is invalid' do
            expect(circle).not_to be_valid
            expect(circle.errors[:base]).to include('Circle cannot overlap with other circles')
          end
        end

        context 'when circles touch but do not overlap' do
          let(:circle) { build(:circle, frame: frame, diameter: 30.0, center_x: 175.0, center_y: 100.0) }

          it 'is valid' do
            expect(circle).to be_valid
          end
        end

        context 'when updating existing circle' do
          let!(:circle) { create(:circle, frame: frame, diameter: 30.0, center_x: 150.0, center_y: 150.0) }

          it 'allows updating without overlap check against self' do
            circle.update!(diameter: 40.0)
            expect(circle).to be_valid
          end
        end
      end
    end
  end

  describe 'concerns' do
    it 'includes GeometryCalculations' do
      expect(Circle.ancestors).to include(GeometryCalculations)
    end
  end

  describe 'instance methods' do
    let(:frame) { create(:frame, width: 200.0, height: 200.0, center_x: 100.0, center_y: 100.0) }
    let(:circle) { create(:circle, frame: frame, diameter: 60.0, center_x: 100.0, center_y: 100.0) }

    describe '#radius' do
      it 'returns half of diameter' do
        expect(circle.radius).to eq(30.0)
      end

      it 'returns float value' do
        expect(circle.radius).to be_a(BigDecimal)
      end
    end

    describe '#distance_to' do
      let(:other_frame) { create(:frame, width: 200.0, height: 200.0, center_x: 300.0, center_y: 300.0) }
      let(:other_circle) { create(:circle, frame: other_frame, center_x: 300.0, center_y: 300.0) }

      it 'calculates euclidean distance correctly' do
        expected_distance = Math.sqrt((100.0 - 300.0)**2 + (100.0 - 300.0)**2)
        expect(circle.distance_to(other_circle)).to be_within(0.001).of(expected_distance)
      end

      it 'returns same distance regardless of order' do
        expect(circle.distance_to(other_circle)).to eq(other_circle.distance_to(circle))
      end
    end
  end

  describe 'edge cases and business rules' do
    let(:frame) { create(:frame, width: 200.0, height: 200.0, center_x: 100.0, center_y: 100.0) }

    describe 'circle positioning within frame' do
      context 'when circle is at frame center' do
        let(:circle) { build(:circle, frame: frame, diameter: 100.0, center_x: 100.0, center_y: 100.0) }

        it 'fits perfectly' do
          expect(circle).to be_valid
        end
      end

      context 'when circle is at frame edge' do
        let(:circle) { build(:circle, frame: frame, diameter: 200.0, center_x: 100.0, center_y: 100.0) }

        it 'fits exactly (touching edges)' do
          expect(circle).to be_valid
        end
      end

      context 'when circle extends beyond frame' do
        let(:circle) { build(:circle, frame: frame, diameter: 250.0, center_x: 100.0, center_y: 100.0) }

        it 'does not fit' do
          expect(circle).not_to be_valid
        end
      end
    end

    describe 'circle overlap scenarios' do
      let!(:existing_circle) { create(:circle, frame: frame, diameter: 50.0, center_x: 100.0, center_y: 100.0) }

      context 'when circles are far apart' do
        let(:circle) { build(:circle, frame: frame, diameter: 30.0, center_x: 150.0, center_y: 150.0) }

        it 'does not overlap' do
          expect(circle).to be_valid
        end
      end

      context 'when circles are close but not touching' do
        let(:circle) { build(:circle, frame: frame, diameter: 30.0, center_x: 180.0, center_y: 100.0) }

        it 'does not overlap' do
          expect(circle).to be_valid
        end
      end

      context 'when circles are touching' do
        let(:circle) { build(:circle, frame: frame, diameter: 30.0, center_x: 175.0, center_y: 100.0) }

        it 'does not overlap (touching is allowed)' do
          expect(circle).to be_valid
        end
      end

      context 'when circles partially overlap' do
        let(:circle) { build(:circle, frame: frame, diameter: 30.0, center_x: 120.0, center_y: 100.0) }

        it 'overlaps and is invalid' do
          expect(circle).not_to be_valid
        end
      end

      context 'when circles completely overlap' do
        let(:circle) { build(:circle, frame: frame, diameter: 30.0, center_x: 100.0, center_y: 100.0) }

        it 'overlaps and is invalid' do
          expect(circle).not_to be_valid
        end
      end
    end

    describe 'diameter edge cases' do
      context 'with very small diameter' do
        let(:circle) { build(:circle, frame: frame, diameter: 0.1, center_x: 100.0, center_y: 100.0) }

        it 'is valid' do
          expect(circle).to be_valid
        end
      end

      context 'with zero diameter' do
        let(:circle) { build(:circle, frame: frame, diameter: 0.0) }

        it 'is invalid' do
          expect(circle).not_to be_valid
          expect(circle.errors[:diameter]).to include('must be greater than 0')
        end
      end

      context 'with negative diameter' do
        let(:circle) { build(:circle, frame: frame, diameter: -10.0) }

        it 'is invalid' do
          expect(circle).not_to be_valid
          expect(circle.errors[:diameter]).to include('must be greater than 0')
        end
      end
    end
  end
end
