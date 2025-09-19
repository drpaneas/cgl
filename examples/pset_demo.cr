require "../src/cgl"

frame = 0

_init do
end

_update do
  frame += 1
end

_draw do
  cls() # Clear with black

  # Example from PICO-8 documentation - should be clearly visible now!
  pset(10, 20, 8) # Draw at (10,20), a red pixel
  pset(20, 30)    # Draw at (20,30), still red (color persists)

  color(12)    # Set draw color to #12, blue
  pset(30, 40) # Draw at (30,40), a blue pixel

  # Draw animated sine wave
  64.times do |i|
    y = 64 + (Math.sin((frame + i) * 0.1) * 20).to_i
    pset(i, y, 8 + (i % 8)) # Rainbow colors
  end

  # Draw color palette demonstration
  16.times do |c|
    pset(10 + c * 6, 10, c) # All 16 PICO-8 colors
  end

  # Draw corner markers (should be clearly visible now)
  pset(0, 0, 7)     # Top-left white
  pset(127, 0, 7)   # Top-right white
  pset(0, 127, 7)   # Bottom-left white
  pset(127, 127, 7) # Bottom-right white
end
