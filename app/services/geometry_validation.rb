class GeometryValidation
  include GeometryCalculations

  # Checa se um círculo cabe dentro de um frame
  def circles_fit_inside_frame?(circle, frame)
    circle.center_x - circle.radius >= frame.left_edge &&
    circle.center_x + circle.radius <= frame.right_edge &&
    circle.center_y - circle.radius >= frame.bottom_edge &&
    circle.center_y + circle.radius <= frame.top_edge
  end

  # Checa se dois círculos se sobrepõem
  def circles_overlap?(circle1, circle2)
    return false if (circle1.nil? || circle2.nil?) & (circle1.id == circle2.id)

    distance = circle1.distance_to(circle2)
    distance < (circle1.radius + circle2.radius)
  end

  # Checa se dois círculos se tocam
  def circles_touch?(circle1, circle2)
    return false if (circle1.nil? || circle2.nil?) & (circle1.id == circle2.id)

    distance = circle1.distance_to(circle2)
    distance == (circle1.radius + circle2.radius)
  end

  # Checa se dois frames se sobrepõem
  def frames_overlap?(frame1, frame2)
    return false if frame1.id == frame2.id

    frame1.center_x - frame1.width / 2.0 < frame2.center_x + frame2.width / 2.0 &&
    frame1.center_x + frame1.width / 2.0 > frame2.center_x - frame2.width / 2.0 &&
    frame1.center_y - frame1.height / 2.0 < frame2.center_y + frame2.height / 2.0 &&
    frame1.center_y + frame1.height / 2.0 > frame2.center_y - frame2.height / 2.0
  end

  def circle_within_radius?(circle, options)
    center_x = options[:center_x]
    center_y = options[:center_y]
    radius = options[:radius]

    distance_to_center = euclidean_distance(circle.center_x, circle.center_y, center_x, center_y)

    distance_to_center + circle.radius <= radius
  end
end
