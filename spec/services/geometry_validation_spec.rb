require 'rails_helper'

RSpec.describe GeometryValidation, type: :service do
  let(:geometry_validation) { described_class.new }

  describe '#circles_fit_inside_frame?' do
    let(:frame) { create(:frame, width: 200.0, height: 200.0, center_x: 100.0, center_y: 100.0) }

    context 'when circle fits completely inside frame' do
      let(:circle) { create(:circle, frame: frame, diameter: 100.0, center_x: 100.0, center_y: 100.0) }

      it 'returns true' do
        expect(geometry_validation.circles_fit_inside_frame?(circle, frame)).to be true
      end
    end

    context 'when circle touches frame edges' do
      let(:circle) { create(:circle, frame: frame, diameter: 200.0, center_x: 100.0, center_y: 100.0) }

      it 'returns true' do
        expect(geometry_validation.circles_fit_inside_frame?(circle, frame)).to be true
      end
    end

    context 'when circle extends beyond frame' do
      let(:circle) { build(:circle, frame: frame, diameter: 250.0, center_x: 100.0, center_y: 100.0) }

      it 'returns false' do
        expect(geometry_validation.circles_fit_inside_frame?(circle, frame)).to be false
      end
    end

    context 'when circle is positioned at frame corner' do
      let(:circle) { build(:circle, frame: frame, diameter: 100.0, center_x: 50.0, center_y: 50.0) }

      it 'returns true' do
        expect(geometry_validation.circles_fit_inside_frame?(circle, frame)).to be true
      end
    end

    context 'when circle extends beyond specific edges' do
      context 'beyond left edge' do
        let(:circle) { build(:circle, frame: frame, diameter: 100.0, center_x: 25.0, center_y: 100.0) }

        it 'returns false' do
          expect(geometry_validation.circles_fit_inside_frame?(circle, frame)).to be false
        end
      end

      context 'beyond right edge' do
        let(:circle) { build(:circle, frame: frame, diameter: 100.0, center_x: 175.0, center_y: 100.0) }

        it 'returns false' do
          expect(geometry_validation.circles_fit_inside_frame?(circle, frame)).to be false
        end
      end

      context 'beyond top edge' do
        let(:circle) { build(:circle, frame: frame, diameter: 100.0, center_x: 100.0, center_y: 175.0) }

        it 'returns false' do
          expect(geometry_validation.circles_fit_inside_frame?(circle, frame)).to be false
        end
      end

      context 'beyond bottom edge' do
        let(:circle) { build(:circle, frame: frame, diameter: 100.0, center_x: 100.0, center_y: 25.0) }

        it 'returns false' do
          expect(geometry_validation.circles_fit_inside_frame?(circle, frame)).to be false
        end
      end
    end
  end

  describe '#circles_overlap?' do
    let(:frame) { create(:frame) }

    context 'when circles do not overlap' do
      let(:circle1) { build(:circle, frame: frame, diameter: 50.0, center_x: 100.0, center_y: 100.0) }
      let(:circle2) { build(:circle, frame: frame, diameter: 30.0, center_x: 200.0, center_y: 200.0) }

      it 'returns false' do
        expect(geometry_validation.circles_overlap?(circle1, circle2)).to be false
      end
    end

    context 'when circles partially overlap' do
      let(:circle1) { build(:circle, frame: frame, diameter: 50.0, center_x: 100.0, center_y: 100.0) }
      let(:circle2) { build(:circle, frame: frame, diameter: 30.0, center_x: 120.0, center_y: 100.0) }

      it 'returns true' do
        expect(geometry_validation.circles_overlap?(circle1, circle2)).to be true
      end
    end

    context 'when circles completely overlap' do
      let(:circle1) { build(:circle, frame: frame, diameter: 50.0, center_x: 100.0, center_y: 100.0) }
      let(:circle2) { build(:circle, frame: frame, diameter: 30.0, center_x: 100.0, center_y: 100.0) }

      it 'returns true' do
        expect(geometry_validation.circles_overlap?(circle1, circle2)).to be true
      end
    end

    context 'when circles touch but do not overlap' do
      let(:circle1) { build(:circle, frame: frame, diameter: 50.0, center_x: 100.0, center_y: 100.0) }
      let(:circle2) { build(:circle, frame: frame, diameter: 30.0, center_x: 175.0, center_y: 100.0) }

      it 'returns false' do
        expect(geometry_validation.circles_overlap?(circle1, circle2)).to be false
      end
    end

    context 'when circles are the same object' do
      let(:circle) { build(:circle, frame: frame, diameter: 50.0, center_x: 100.0, center_y: 100.0) }

      it 'returns true (overlaps with itself)' do
        expect(geometry_validation.circles_overlap?(circle, circle)).to be true
      end
    end

    context 'with different sized circles' do
      let(:large_circle) { build(:circle, frame: frame, diameter: 100.0, center_x: 100.0, center_y: 100.0) }
      let(:small_circle) { build(:circle, frame: frame, diameter: 20.0, center_x: 150.0, center_y: 100.0) }

      it 'correctly identifies overlap' do
        expect(geometry_validation.circles_overlap?(large_circle, small_circle)).to be true
      end
    end
  end

  describe '#circles_touch?' do
    let(:frame) { create(:frame, width: 200.0, height: 200.0, center_x: 100.0, center_y: 100.0) }

    context 'when circles touch exactly' do
      let(:circle1) { build(:circle, frame: frame, diameter: 50.0, center_x: 100.0, center_y: 100.0) }
      let(:circle2) { build(:circle, frame: frame, diameter: 30.0, center_x: 140.0, center_y: 100.0) }

      it 'returns true' do
        expect(geometry_validation.circles_touch?(circle1, circle2)).to be true
      end
    end

    context 'when circles do not touch' do
      let(:circle1) { build(:circle, frame: frame, diameter: 50.0, center_x: 100.0, center_y: 100.0) }
      let(:circle2) { build(:circle, frame: frame, diameter: 30.0, center_x: 200.0, center_y: 100.0) }

      it 'returns false' do
        expect(geometry_validation.circles_touch?(circle1, circle2)).to be false
      end
    end

    context 'when circles overlap' do
      let(:circle1) { build(:circle, frame: frame, diameter: 50.0, center_x: 100.0, center_y: 100.0) }
      let(:circle2) { build(:circle, frame: frame, diameter: 30.0, center_x: 120.0, center_y: 100.0) }

      it 'returns false' do
        expect(geometry_validation.circles_touch?(circle1, circle2)).to be false
      end
    end
  end

  describe '#frames_overlap?' do
    context 'when frames do not overlap' do
      let(:frame1) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 200.0) }
      let(:frame2) { build(:frame, center_x: 400.0, center_y: 400.0, width: 200.0, height: 200.0) }

      it 'returns false' do
        expect(geometry_validation.frames_overlap?(frame1, frame2)).to be false
      end
    end

    context 'when frames partially overlap' do
      let(:frame1) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 200.0) }
      let(:frame2) { build(:frame, center_x: 200.0, center_y: 200.0, width: 200.0, height: 200.0) }

      it 'returns true' do
        expect(geometry_validation.frames_overlap?(frame1, frame2)).to be true
      end
    end

    context 'when frames completely overlap' do
      let(:frame1) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 200.0) }
      let(:frame2) { build(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 200.0) }

      it 'returns true' do
        expect(geometry_validation.frames_overlap?(frame1, frame2)).to be true
      end
    end

    context 'when frames touch but do not overlap' do
      let(:frame1) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 200.0) }
      let(:frame2) { build(:frame, center_x: 300.0, center_y: 100.0, width: 200.0, height: 200.0) }

      it 'returns false' do
        expect(geometry_validation.frames_overlap?(frame1, frame2)).to be false
      end
    end

    context 'with different sized frames' do
      let(:large_frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 400.0, height: 400.0) }
      let(:small_frame) { build(:frame, center_x: 200.0, center_y: 200.0, width: 100.0, height: 100.0) }

      it 'correctly identifies overlap' do
        expect(geometry_validation.frames_overlap?(large_frame, small_frame)).to be true
      end
    end
  end

  describe '#circle_within_radius?' do
    let(:frame) { create(:frame) }
    let(:circle) { build(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 20.0) }

    context 'when circle is within radius' do
      let(:options) { { center_x: 100.0, center_y: 100.0, radius: 50.0 } }

      it 'returns true' do
        expect(geometry_validation.circle_within_radius?(circle, options)).to be true
      end
    end

    context 'when circle is outside radius' do
      let(:options) { { center_x: 200.0, center_y: 200.0, radius: 50.0 } }

      it 'returns false' do
        expect(geometry_validation.circle_within_radius?(circle, options)).to be false
      end
    end

    context 'when circle is exactly at radius boundary' do
      let(:options) { { center_x: 100.0, center_y: 100.0, radius: 10.0 } }

      it 'returns true' do
        expect(geometry_validation.circle_within_radius?(circle, options)).to be true
      end
    end

    context 'with different circle sizes' do
      let(:large_circle) { build(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 100.0) }
      let(:options) { { center_x: 100.0, center_y: 100.0, radius: 60.0 } }

      it 'considers circle radius in calculation' do
        expect(geometry_validation.circle_within_radius?(large_circle, options)).to be true
      end
    end
  end
end
