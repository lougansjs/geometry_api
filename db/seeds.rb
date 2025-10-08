# Geometry API Seeds
# Creates 150 frames with 12-400 circles each, respecting all validations

puts "🌱 Starting Geometry API seeds..."

# Clear existing data
puts "🧹 Clearing existing data..."
Circle.destroy_all
Frame.destroy_all

# Create frames
puts "📦 Creating 150 frames..."
frames = []

150.times do |i|
  attempts = 0
  frame = nil

  loop do
    attempts += 1
    break if attempts > 50 # Prevent infinite loops

    # Generate random frame dimensions and position
    width = rand(200.0..800.0).round(2)
    height = rand(200.0..600.0).round(2)
    center_x = rand(100.0..900.0).round(2)
    center_y = rand(100.0..700.0).round(2)

    frame = Frame.new(
      width: width,
      height: height,
      center_x: center_x,
      center_y: center_y
    )

    # Try to save, if validation fails, try again
    if frame.valid?
      frame.save!
      frames << frame
      puts "✅ Frame #{i + 1}/150 created: #{width}x#{height} at (#{center_x}, #{center_y})"
      break
    end
  end

  if frame.nil? || !frame.persisted?
    puts "⚠️  Failed to create frame #{i + 1} after 50 attempts"
  end
end

puts "📊 Created #{frames.count} frames successfully"

# Create circles for each frame
total_circles = 0
geometry_validator = GeometryValidation.new

frames.each_with_index do |frame, frame_index|
  circle_count = rand(12..400)
  created_circles = 0
  attempts = 0
  max_attempts = circle_count * 10 # Allow more attempts for circles

  puts "🔵 Creating #{circle_count} circles for frame #{frame_index + 1}/#{frames.count}..."

  circle_count.times do |circle_index|
    attempts += 1
    break if attempts > max_attempts

    # Generate random circle within frame bounds
    # Leave margin for radius to ensure circle fits inside frame
    max_radius = [ frame.width, frame.height ].min / 4.0
    diameter = rand(10.0..max_radius * 2).round(2)
    radius = diameter / 2.0

    # Calculate safe position within frame
    min_x = frame.left_edge + radius
    max_x = frame.right_edge - radius
    min_y = frame.bottom_edge + radius
    max_y = frame.top_edge - radius

    # Ensure valid bounds
    if min_x >= max_x || min_y >= max_y
      puts "⚠️  Frame #{frame_index + 1} too small for circles, skipping remaining"
      break
    end

    center_x = rand(min_x..max_x).round(2)
    center_y = rand(min_y..max_y).round(2)

    circle = Circle.new(
      frame: frame,
      diameter: diameter,
      center_x: center_x,
      center_y: center_y
    )

    # Check if circle fits inside frame
    unless geometry_validator.circles_fit_inside_frame?(circle, frame)
      next # Try again with different position
    end

    # Check if circle overlaps with existing circles
    overlaps = false
    frame.circles.each do |existing_circle|
      if geometry_validator.circles_overlap?(circle, existing_circle)
        overlaps = true
        break
      end
    end

    next if overlaps

    # Save the circle
    if circle.save
      created_circles += 1
      total_circles += 1
    end
  end

  puts "✅ Frame #{frame_index + 1}: Created #{created_circles}/#{circle_count} circles"
end

puts "🎉 Seeds completed!"
puts "📊 Final statistics:"
puts "   - Frames: #{Frame.count}"
puts "   - Circles: #{Circle.count}"
puts "   - Average circles per frame: #{(Circle.count.to_f / Frame.count).round(2)}"

# Verify data integrity
puts "🔍 Verifying data integrity..."

invalid_frames = Frame.all.select { |f| !f.valid? }
invalid_circles = Circle.all.select { |c| !c.valid? }

if invalid_frames.any?
  puts "❌ Found #{invalid_frames.count} invalid frames"
else
  puts "✅ All frames are valid"
end

if invalid_circles.any?
  puts "❌ Found #{invalid_circles.count} invalid circles"
else
  puts "✅ All circles are valid"
end

puts "🌱 Seeds finished!"
