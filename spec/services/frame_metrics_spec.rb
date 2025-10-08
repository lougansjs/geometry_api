require 'rails_helper'

RSpec.describe FrameMetrics, type: :service do
  let(:frame) { create(:frame, center_x: 200.0, center_y: 200.0, width: 400.0, height: 400.0) }
  let(:frame_metrics) { described_class.new(frame) }

  describe '#initialize' do
    it 'sets frame and circles' do
      expect(frame_metrics.frame).to eq(frame)
      expect(frame_metrics.circles).to eq(frame.circles)
    end
  end

  describe '#calculate' do
    context 'when frame has no circles' do
      it 'returns base metrics only' do
        result = frame_metrics.calculate

        expect(result).to include(
          frame: frame,
          total_circles: 0
        )

        expect(result).not_to have_key(:highest_circles)
        expect(result).not_to have_key(:lowest_circles)
        expect(result).not_to have_key(:leftmost_circles)
        expect(result).not_to have_key(:rightmost_circles)
      end
    end

    context 'when frame has circles' do
      let!(:circle1) { create(:circle, frame: frame, center_x: 100.0, center_y: 200.0, diameter: 30.0) }
      let!(:circle2) { create(:circle, frame: frame, center_x: 200.0, center_y: 100.0, diameter: 40.0) }
      let!(:circle3) { create(:circle, frame: frame, center_x: 50.0, center_y: 150.0, diameter: 20.0) }

      it 'returns complete metrics' do
        result = frame_metrics.calculate

        expect(result).to include(
          frame: frame,
          total_circles: 3,
          highest_circles: [ circle1 ],
          lowest_circles: [ circle2 ],
          leftmost_circles: [ circle3 ],
          rightmost_circles: [ circle2 ]
        )
      end

      it 'identifies highest circle correctly' do
        result = frame_metrics.calculate
        expect(result[:highest_circles]).to eq([ circle1 ])
      end

      it 'identifies lowest circle correctly' do
        result = frame_metrics.calculate
        expect(result[:lowest_circles]).to eq([ circle2 ])
      end

      it 'identifies leftmost circle correctly' do
        result = frame_metrics.calculate
        expect(result[:leftmost_circles]).to eq([ circle3 ])
      end

      it 'identifies rightmost circle correctly' do
        result = frame_metrics.calculate
        expect(result[:rightmost_circles]).to eq([ circle2 ])
      end
    end

    context 'with circles at same coordinates' do
      let!(:circle1) { create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 30.0) }
      let!(:circle2) { create(:circle, frame: frame, center_x: 300.0, center_y: 100.0, diameter: 40.0) }

      it 'handles ties correctly' do
        result = frame_metrics.calculate

        expect(result[:highest_circles]).to eq([ circle1, circle2 ])
        expect(result[:lowest_circles]).to eq([ circle1, circle2 ])
        expect(result[:leftmost_circles]).to be_in([ [ circle1 ], [ circle2 ] ])
        expect(result[:rightmost_circles]).to be_in([ [ circle1 ], [ circle2 ] ])
      end
    end

    context 'with single circle' do
      let!(:circle) { create(:circle, frame: frame, center_x: 150.0, center_y: 150.0, diameter: 50.0) }

      it 'returns same circle for all positions' do
        result = frame_metrics.calculate

        expect(result[:highest_circles]).to eq([ circle ])
        expect(result[:lowest_circles]).to eq([ circle ])
        expect(result[:leftmost_circles]).to eq([ circle ])
        expect(result[:rightmost_circles]).to eq([ circle ])
      end
    end
  end

  describe 'private methods' do
    let!(:circle1) { create(:circle, frame: frame, center_x: 100.0, center_y: 200.0, diameter: 30.0) }
    let!(:circle2) { create(:circle, frame: frame, center_x: 200.0, center_y: 100.0, diameter: 40.0) }

    describe '#base_metrics' do
      it 'returns frame and total circles count' do
        result = frame_metrics.send(:base_metrics)

        expect(result).to eq({
          frame: frame,
          total_circles: 2
        })
      end
    end

    describe '#circles_metrics' do
      it 'returns all circle position metrics' do
        result = frame_metrics.send(:circles_metrics)

        expect(result).to include(
          highest_circles: [ circle1 ],
          lowest_circles: [ circle2 ],
          leftmost_circles: [ circle1 ],
          rightmost_circles: [ circle2 ]
        )
      end
    end

    describe '#highest_circle' do
      it 'returns circle with highest center_y' do
        expect(frame_metrics.send(:highest_circles)).to eq([ circle1 ])
      end
    end

    describe '#lowest_circle' do
      it 'returns circle with lowest center_y' do
        expect(frame_metrics.send(:lowest_circles)).to eq([ circle2 ])
      end
    end

    describe '#leftmost_circle' do
      it 'returns circle with lowest center_x' do
        expect(frame_metrics.send(:leftmost_circles)).to eq([ circle1 ])
      end
    end

    describe '#rightmost_circle' do
      it 'returns circle with highest center_x' do
        expect(frame_metrics.send(:rightmost_circles)).to eq([ circle2 ])
      end
    end
  end

  describe 'edge cases' do
    context 'with circles at extreme positions' do
      let!(:leftmost) { create(:circle, frame: frame, center_x: 10, center_y: 100.0, diameter: 20.0) }
      let!(:rightmost) { create(:circle, frame: frame, center_x: 350.0, center_y: 100.0, diameter: 20.0) }
      let!(:highest) { create(:circle, frame: frame, center_x: 350.0, center_y: 350.0, diameter: 20.0) }
      let!(:lowest) { create(:circle, frame: frame, center_x: 30.0, center_y: 40.0, diameter: 20.0) }

      it 'correctly identifies extreme positions' do
        result = frame_metrics.calculate

        expect(result[:leftmost_circles]).to eq([ leftmost ])
        expect(result[:rightmost_circles]).to eq([ rightmost, highest ])
        expect(result[:highest_circles]).to eq([ highest ])
        expect(result[:lowest_circles]).to eq([ lowest ])
      end
    end

    context 'with decimal coordinates' do
      let!(:circle1) { create(:circle, frame: frame, center_x: 100.123, center_y: 200.456, diameter: 20.0) }
      let!(:circle2) { create(:circle, frame: frame, center_x: 200.124, center_y: 100.455, diameter: 20.0) }

      it 'handles decimal precision correctly' do
        result = frame_metrics.calculate

        expect(result[:leftmost_circles]).to eq([ circle1 ])
        expect(result[:rightmost_circles]).to eq([ circle2 ])
        expect(result[:lowest_circles]).to eq([ circle2 ])
        expect(result[:highest_circles]).to eq([ circle1 ])
      end
    end
  end

  describe 'data consistency' do
    let!(:circle1) { create(:circle, frame: frame, center_x: 100.0, center_y: 200.0, diameter: 30.0) }
    let!(:circle2) { create(:circle, frame: frame, center_x: 200.0, center_y: 100.0, diameter: 40.0) }

    it 'maintains consistency across multiple calls' do
      result1 = frame_metrics.calculate
      result2 = frame_metrics.calculate

      expect(result1).to eq(result2)
    end

    it 'reflects changes when circles are added' do
      initial_result = frame_metrics.calculate
      expect(initial_result[:total_circles]).to eq(2)

      create(:circle, frame: frame)
      new_result = frame_metrics.calculate
      expect(new_result[:total_circles]).to eq(3)
    end
  end
end
