class FrameMetricsSerializer
  def initialize(metrics_data)
    @data = metrics_data
  end

  def as_json
    return { frame: serialize_frame(@data[:frame]) } if @data[:total_circles].zero?

    {
      frame: serialize_frame(@data[:frame]),
      total_circles: @data[:total_circles],
      highest_circles: @data[:highest_circles].map { |circle| serialize_circle(circle) },
      lowest_circles: @data[:lowest_circles].map { |circle| serialize_circle(circle) },
      leftmost_circles: @data[:leftmost_circles].map { |circle| serialize_circle(circle) },
      rightmost_circles: @data[:rightmost_circles].map { |circle| serialize_circle(circle) }
    }
  end

  private

  def serialize_circle(circle)
    return nil unless circle
    CircleCoordsSerializer.new(circle).as_json
  end

  def serialize_frame(frame)
    return nil unless frame
    FrameSerializer.new(frame).as_json.except(:circles)
  end
end
