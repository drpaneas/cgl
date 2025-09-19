require "../src/cgl"

frame = 0

_init do
  puts "Rectangle demo - showcasing PICO-8 rect() and rectfill() functions"
end

_update do
  frame += 1
end

_draw do
  cls()  # Clear with black
  
  # Test 1: Basic rectangle outlines
  rect(10, 10, 30, 25, 8)   # Red rectangle
  rect(35, 10, 55, 25, 12)  # Blue rectangle  
  rect(60, 10, 80, 25, 11)  # Green rectangle
  
  # Test 2: Basic filled rectangles
  rectfill(10, 35, 25, 50, 9)   # Orange filled
  rectfill(30, 35, 45, 50, 14)  # Pink filled
  rectfill(50, 35, 65, 50, 10)  # Yellow filled
  
  # Test 3: Color persistence (PICO-8 behavior)
  color(7)                      # Set draw color to white
  rect(75, 35, 90, 50)         # Should be white outline
  rectfill(95, 35, 110, 50)    # Should be white filled
  
  # Test 4: Overlapping rectangles
  rectfill(10, 60, 40, 80, 1)  # Dark blue background
  rect(15, 65, 35, 75, 7)      # White outline on top
  rectfill(20, 68, 30, 72, 8)  # Red filled on top
  
  # Test 5: Animated growing rectangles
  size = (Math.sin(frame * 0.1) * 10 + 15).to_i
  center_x = 80
  center_y = 70
  
  # Animated outline
  rect(center_x - size, center_y - size//2, 
       center_x + size, center_y + size//2, 13)  # Indigo
  
  # Animated filled rectangle inside
  inner_size = size // 2
  rectfill(center_x - inner_size, center_y - inner_size//2,
           center_x + inner_size, center_y + inner_size//2, 6)  # Light grey
  
  # Test 6: Grid of small rectangles
  4.times do |row|
    5.times do |col|
      x = 10 + col * 12
      y = 90 + row * 8
      if (row + col) % 2 == 0
        rectfill(x, y, x + 8, y + 5, 2)  # Dark purple
      else
        rect(x, y, x + 8, y + 5, 6)      # Light grey outline
      end
    end
  end
  
  # Test 7: Nested rectangles
  nest_x = 90
  nest_y = 90
  5.times do |i|
    size = i * 4 + 2
    color_index = i + 8
    rect(nest_x - size, nest_y - size, 
         nest_x + size, nest_y + size, color_index)
  end
  
  # Test 8: Edge case - single pixel rectangles
  rect(5, 5, 5, 5, 15)      # Single pixel rect (should be 1 pixel)
  rectfill(7, 5, 7, 5, 15)  # Single pixel rectfill (should be 1 pixel)
end
