class Circle < ApplicationRecord
  include GeometryCalculations

  belongs_to :frame, required: true

  before_validation :block_if_coords_nil

  validates :diameter, presence: true, numericality: { greater_than: 0 }
  validates :center_x, :center_y, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :must_fit_inside_frame, on: [ :create, :update ]
  validate :must_not_touch_other_circles, on: [ :create, :update ]

  def radius
    diameter / 2.0
  end

  def distance_to(other_circle)
    euclidean_distance(center_x, center_y, other_circle.center_x, other_circle.center_y)
  end

  private

  def block_if_coords_nil
    return if frame.nil?

    errors.add(:center_x, "cannot be null") if center_x.nil?
    errors.add(:center_y, "cannot be null") if center_y.nil?

    throw(:abort) if errors.any?
  end

  def must_fit_inside_frame
    return unless frame.present?

    geometry_validator = GeometryValidation.new
    unless geometry_validator.circles_fit_inside_frame?(self, frame)
      errors.add(:base, :invalid, message: "Circle must fit completely inside the frame")
    end
  end

  def must_not_touch_other_circles
    return unless frame.present?

    geometry_validator = GeometryValidation.new
    frame.circles.where.not(id: id).each do |other_circle|
      if geometry_validator.circles_overlap?(self, other_circle)
        errors.add(:base, "Circle cannot overlap with other circles")
        break
      end
    end
  end
end
