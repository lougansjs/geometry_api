class FrameMetrics
  attr_reader :frame, :circles

  def initialize(frame)
    @frame = frame
    @circles = frame.circles
  end

  def calculate
    return base_metrics if circles.empty?

    base_metrics.merge(circles_metrics)
  end

  private

  def base_metrics
    {
      frame: frame,
      total_circles: circles.count
    }
  end

  def circles_metrics
    {
      highest_circles: highest_circles,
      lowest_circles: lowest_circles,
      leftmost_circles: leftmost_circles,
      rightmost_circles: rightmost_circles
    }
  end

  def highest_circles
    return @highest_circles if defined?(@highest_circles)

    max_y = circles.maximum(:center_y)
    @highest_circles = max_y.nil? ? [] : circles.where(center_y: max_y).to_a
  end

  def lowest_circles
    return @lowest_circles if defined?(@lowest_circles)

    min_y = circles.minimum(:center_y)
    @lowest_circles = min_y.nil? ? [] : circles.where(center_y: min_y).to_a
  end

  def leftmost_circles
    return @leftmost_circles if defined?(@leftmost_circles)

    min_x = circles.minimum(:center_x)
    @leftmost_circles = min_x.nil? ? [] : circles.where(center_x: min_x).to_a
  end

  def rightmost_circles
    return @rightmost_circles if defined?(@rightmost_circles)

    max_x = circles.maximum(:center_x)
    @rightmost_circles = max_x.nil? ? [] : circles.where(center_x: max_x).to_a
  end
end
