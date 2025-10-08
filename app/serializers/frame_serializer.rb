class FrameSerializer < ActiveModel::Serializer
  attributes :id, :width, :height, :center_x, :center_y

  has_many :circles
end