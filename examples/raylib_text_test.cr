require "../src/cgl"

# Test using Raylib's native text rendering - potentially much faster
def print_raylib(text, x, y, col)
  # Use Raylib's optimized text rendering
  pixel_color = COLORS.unsafe_fetch(col & 15)

  # Raylib can render text much faster than pixel-by-pixel
  # Scale coordinates to match our scaling
  Raylib.draw_text(text, x << 2, y << 2, 16, pixel_color) # Font size 16 for 4x scale
end

_init do
  puts "Raylib Native Text Performance Test"

  # Test our current implementation
  start = Time.monotonic
  1000.times do |i|
    print("HELLO WORLD", 10, 10, 7)
  end
  current_time = Time.monotonic - start

  # Test Raylib native text
  start = Time.monotonic
  1000.times do |i|
    print_raylib("HELLO WORLD", 10, 10, 7)
  end
  raylib_time = Time.monotonic - start

  puts "Current print: #{(current_time.total_milliseconds).round(3)}ms"
  puts "Raylib text:   #{(raylib_time.total_milliseconds).round(3)}ms"
  puts "Speedup: #{(current_time / raylib_time).round(2)}x"

  exit
end

_update do
end

_draw do
  cls()
end
