FactoryBot.define do
  factory :circle do
    association :frame
    diameter { rand(10.0..50.0).round(2) }

    # Calcular coordenadas que cabem no frame
    center_x do
      frame = instance.frame || Frame.first || create(:frame)
      min_x = frame.left_edge + 25.0  # Margem de 25px
      max_x = frame.right_edge - 25.0
      rand(min_x..max_x).round(2)
    end

    center_y do
      frame = instance.frame || Frame.first || create(:frame)
      min_y = frame.bottom_edge + 25.0  # Margem de 25px
      max_y = frame.top_edge - 25.0
      rand(min_y..max_y).round(2)
    end

    trait :small do
      diameter { 10.0 }
    end

    trait :large do
      diameter { 100.0 }
    end

    trait :at_frame_center do
      center_x { frame.center_x }
      center_y { frame.center_y }
    end

    trait :at_frame_edge do
      center_x { frame.left_edge + diameter / 2.0 }
      center_y { frame.bottom_edge + diameter / 2.0 }
    end

    trait :outside_frame do
      center_x { frame.right_edge + 50.0 }
      center_y { frame.top_edge + 50.0 }
    end

    trait :overlapping do
      center_x { 200.0 }
      center_y { 200.0 }
      diameter { 50.0 }
    end

    trait :touching do
      center_x { 150.0 }
      center_y { 200.0 }
      diameter { 30.0 }
    end

    trait :non_overlapping do
      center_x { 300.0 }
      center_y { 300.0 }
      diameter { 20.0 }
    end

    trait :with_zero_diameter do
      diameter { 0.0 }
    end

    trait :with_negative_diameter do
      diameter { -10.0 }
    end
  end
end
