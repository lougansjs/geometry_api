FactoryBot.define do
  factory :frame do
    sequence(:width) { |n| [ 200.0 + (n * 10), 1000.0 ].min }
    sequence(:height) { |n| [ 200.0 + (n * 10), 1000.0 ].min }
    sequence(:center_x) { |n| [ 100.0 + (n * 50), 1000.0 ].min }
    sequence(:center_y) { |n| [ 100.0 + (n * 50), 1000.0 ].min }

    trait :small do
      width { 100.0 }
      height { 100.0 }
    end

    trait :large do
      width { 1000.0 }
      height { 1000.0 }
    end

    trait :overlapping do
      center_x { 200.0 }
      center_y { 200.0 }
      width { 300.0 }
      height { 300.0 }
    end

    trait :non_overlapping do
      center_x { 500.0 }
      center_y { 500.0 }
      width { 100.0 }
      height { 100.0 }
    end

    trait :with_circles do
      after(:create) do |frame|
        create_list(:circle, 3, frame: frame)
      end
    end

    trait :with_many_circles do
      after(:create) do |frame|
        create_list(:circle, 10, frame: frame)
      end
    end
  end
end
