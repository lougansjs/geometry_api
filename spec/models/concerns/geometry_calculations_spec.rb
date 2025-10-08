require 'rails_helper'

RSpec.describe GeometryCalculations, type: :concern do
  let(:test_class) do
    Class.new do
      include GeometryCalculations
    end
  end

  let(:test_instance) { test_class.new }

  describe '#euclidean_distance' do
    it 'calculates distance between two points correctly' do
      distance = test_instance.euclidean_distance(0, 0, 3, 4)
      expect(distance).to eq(5.0)
    end

    it 'calculates distance between same points as zero' do
      distance = test_instance.euclidean_distance(100, 200, 100, 200)
      expect(distance).to eq(0.0)
    end

    it 'calculates distance with negative coordinates' do
      distance = test_instance.euclidean_distance(-1, -1, 2, 3)
      expected = Math.sqrt((-1 - 2)**2 + (-1 - 3)**2)
      expect(distance).to be_within(0.001).of(expected)
    end

    it 'calculates distance with decimal coordinates' do
      distance = test_instance.euclidean_distance(1.5, 2.5, 4.5, 6.5)
      expected = Math.sqrt((1.5 - 4.5)**2 + (2.5 - 6.5)**2)
      expect(distance).to be_within(0.001).of(expected)
    end

    it 'handles very small distances' do
      distance = test_instance.euclidean_distance(0.0001, 0.0001, 0.0002, 0.0002)
      expect(distance).to be > 0
      expect(distance).to be < 0.001
    end

    it 'handles very large distances' do
      distance = test_instance.euclidean_distance(0, 0, 1000000, 1000000)
      expected = Math.sqrt(1000000**2 + 1000000**2)
      expect(distance).to be_within(0.001).of(expected)
    end

    it 'returns a float' do
      distance = test_instance.euclidean_distance(1, 1, 2, 2)
      expect(distance).to be_a(Float)
    end

    it 'is commutative' do
      distance1 = test_instance.euclidean_distance(1, 2, 3, 4)
      distance2 = test_instance.euclidean_distance(3, 4, 1, 2)
      expect(distance1).to eq(distance2)
    end

    context 'with edge cases' do
      it 'handles zero coordinates' do
        distance = test_instance.euclidean_distance(0, 0, 0, 5)
        expect(distance).to eq(5.0)
      end

      it 'handles coordinates on same axis' do
        distance = test_instance.euclidean_distance(0, 0, 5, 0)
        expect(distance).to eq(5.0)
      end

      it 'handles very close coordinates' do
        distance = test_instance.euclidean_distance(1.0, 1.0, 1.0000001, 1.0000001)
        expect(distance).to be > 0
      end
    end

    context 'mathematical properties' do
      it 'satisfies triangle inequality' do
        # For any three points A, B, C: distance(A,C) <= distance(A,B) + distance(B,C)
        a_to_b = test_instance.euclidean_distance(0, 0, 3, 4)
        b_to_c = test_instance.euclidean_distance(3, 4, 6, 8)
        a_to_c = test_instance.euclidean_distance(0, 0, 6, 8)

        expect(a_to_c).to be <= (a_to_b + b_to_c)
      end

      it 'satisfies symmetry' do
        x1, y1, x2, y2 = 1, 2, 3, 4
        distance1 = test_instance.euclidean_distance(x1, y1, x2, y2)
        distance2 = test_instance.euclidean_distance(x2, y2, x1, y1)
        expect(distance1).to eq(distance2)
      end

      it 'satisfies positive definiteness' do
        distance = test_instance.euclidean_distance(1, 1, 2, 2)
        expect(distance).to be >= 0
      end
    end
  end

  describe 'integration with Circle model' do
    let(:frame) { create(:frame, center_x: 0, center_y: 0, width: 300, height: 300) }
    let(:circle1) { create(:circle, frame: frame, center_x: 0, center_y: 0, diameter: 40) }
    let(:circle2) { create(:circle, frame: frame, center_x: 120, center_y: 120, diameter: 40) }

    it 'works correctly when included in Circle' do
      expect(circle1.distance_to(circle2).to_f.round(2)).to eq(169.71)
    end

    it 'uses the same calculation as direct method call' do
      direct_distance = test_instance.euclidean_distance(circle1.center_x, circle1.center_y, circle2.center_x, circle2.center_y)
      method_distance = circle1.distance_to(circle2)
      expect(method_distance).to eq(direct_distance)
    end
  end
end
