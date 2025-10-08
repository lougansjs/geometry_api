class CircleSerializer < ActiveModel::Serializer
  attributes :id, :diameter, :center_x, :center_y
end
