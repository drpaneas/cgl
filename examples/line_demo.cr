require "../src/cgl"

frame = 0

_init do
  puts "Line drawing demo - showcasing PICO-8 line() function"
end

_update do
  frame += 1
end

_draw do
  cls() # Clear with black

  # Test 1: Basic lines with explicit colors
  line(10, 10, 50, 10, 8)  # Red horizontal line
  line(10, 15, 50, 15, 12) # Blue horizontal line
  line(10, 20, 50, 20, 11) # Green horizontal line

  # Test 2: Vertical lines
  line(60, 10, 60, 30, 10) # Yellow vertical line
  line(65, 10, 65, 30, 14) # Pink vertical line

  # Test 3: Diagonal lines
  line(10, 40, 30, 60, 9)  # Orange diagonal
  line(30, 40, 10, 60, 13) # Indigo diagonal (opposite)

  # Test 4: Color persistence (PICO-8 behavior)
  color(7)             # Set draw color to white
  line(70, 10, 90, 30) # Should be white (no color specified)
  line(90, 10, 70, 30) # Should still be white

  # Test 5: Animated rotating lines from center
  center_x = 64
  center_y = 64

  8.times do |i|
    angle = (frame + i * 8) * 0.1
    end_x = center_x + (Math.cos(angle) * 25).to_i
    end_y = center_y + (Math.sin(angle) * 25).to_i
    line(center_x, center_y, end_x, end_y, i + 8)
  end

  # Test 6: Grid pattern
  # Horizontal grid lines
  5.times do |i|
    y = 90 + i * 6
    line(10, y, 50, y, 5) # Dark grey
  end

  # Vertical grid lines
  5.times do |i|
    x = 10 + i * 8
    line(x, 90, x, 114, 5) # Dark grey
  end

  # Test 7: Box outline using lines
  line(80, 90, 120, 90, 6)   # Top
  line(120, 90, 120, 120, 6) # Right
  line(120, 120, 80, 120, 6) # Bottom
  line(80, 120, 80, 90, 6)   # Left

  # Test 8: Star pattern
  star_x = 100
  star_y = 50
  5.times do |i|
    angle1 = i * Math::PI * 2 / 5
    angle2 = (i + 2) * Math::PI * 2 / 5
    x1 = star_x + (Math.cos(angle1) * 15).to_i
    y1 = star_y + (Math.sin(angle1) * 15).to_i
    x2 = star_x + (Math.cos(angle2) * 15).to_i
    y2 = star_y + (Math.sin(angle2) * 15).to_i
    line(x1, y1, x2, y2, 10) # Yellow star
  end
end
