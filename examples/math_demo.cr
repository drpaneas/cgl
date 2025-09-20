require "../src/cgl"

frame = 0

_init do
  puts "Math functions demo - showcasing PICO-8 flr() and rnd() functions"
  
  # Test flr() function examples from PICO-8 docs
  puts "flr(1.99) = #{flr(1.99)}"      # Should print 1
  puts "flr(-5.3) = #{flr(-5.3)}"      # Should print -6
  puts "flr(42.0) = #{flr(42.0)}"      # Should print 42
  puts "flr(0.1) = #{flr(0.1)}"        # Should print 0
  
  # Test rnd() function
  puts "rnd() = #{rnd()}"              # Random 0.0 to 0.999...
  puts "rnd(10) = #{rnd(10)}"          # Random 0.0 to 9.999...
  puts "flr(rnd(10)) = #{flr(rnd(10))}" # Random integer 0-9
end

_update do
  frame += 1
end

_draw do
  cls()  # Clear with black
  
  # Visual demo 1: Random colored pixels
  50.times do |i|
    x = flr(rnd(128))     # Random x coordinate 0-127
    y = flr(rnd(128))     # Random y coordinate 0-127
    col = flr(rnd(16))    # Random color 0-15
    pset(x, y, col)
  end
  
  # Visual demo 2: Random rectangles
  10.times do |i|
    x = flr(rnd(100))
    y = flr(rnd(100))
    w = flr(rnd(20)) + 5  # Width 5-24
    h = flr(rnd(20)) + 5  # Height 5-24
    col = flr(rnd(16))
    
    if flr(rnd(2)) == 0   # 50% chance
      rect(x, y, x + w, y + h, col)
    else
      rectfill(x, y, x + w, y + h, col)
    end
  end
  
  # Visual demo 3: Sine wave with random colors
  64.times do |x|
    # Use flr with sine wave calculation
    y = flr(64 + Math.sin((x + frame) * 0.1) * 20)
    col = flr(rnd(8)) + 8  # Random bright colors (8-15)
    pset(x, y, col)
  end
  
  # Visual demo 4: Random grid pattern
  8.times do |row|
    8.times do |col|
      if flr(rnd(4)) == 0  # 25% chance
        x = col * 15 + 5
        y = row * 15 + 5
        color_val = flr(rnd(16))
        rectfill(x, y, x + 10, y + 10, color_val)
      end
    end
  end
  
  # Visual demo 5: Animated random lines
  20.times do |i|
    x1 = flr(rnd(128))
    y1 = flr(rnd(128))
    # Use frame for animation
    angle = (frame + i) * 0.2
    length = rnd(30) + 10
    x2 = flr(x1 + Math.cos(angle) * length)
    y2 = flr(y1 + Math.sin(angle) * length)
    col = flr(rnd(16))
    line(x1, y1, x2, y2, col)
  end
end
