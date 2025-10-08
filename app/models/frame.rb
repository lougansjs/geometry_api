class Frame < ApplicationRecord
  has_many :circles, dependent: :restrict_with_exception

  before_destroy :has_no_circles, prepend: true

  validates :width, :height, :center_x, :center_y, presence: true
  validates :width, :height, numericality: { greater_than: 0 }

  validate :must_not_touch_other_frames, on: [ :create, :update ], prepend: true

  accepts_nested_attributes_for :circles

  def has_no_circles
    if circles.any?
      errors.add(:base, "Cannot delete frame with associated circles")
      throw :abort
    end
  end

  def left_edge
    center_x - (width / 2.0)
  end

  def right_edge
    center_x + (width / 2.0)
  end

  def top_edge
    center_y + (height / 2.0)
  end

  def bottom_edge
    center_y - (height / 2.0)
  end

  def bounds
    {
      min_x: left_edge,
      max_x: right_edge,
      min_y: bottom_edge,
      max_y: top_edge
    }
  end

  private

  def must_not_touch_other_frames
    geometry_validator = GeometryValidation.new
    Frame.where.not(id: id).each do |other_frame|
      if geometry_validator.frames_overlap?(self, other_frame)
        errors.add(:base, "Frame cannot overlap with other frames")
        break
      end
    end
  end
end

