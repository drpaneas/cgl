require "../src/cgl"

frame = 0

_init do
  puts "Print function demo - showcasing PICO-8 print() function"
end

_update do
  frame += 1
end

_draw do
  cls()  # Clear with black
  
  # Test 1: Basic print with different parameter combinations
  print("HELLO WORLD")                    # Default position and color
  print("RED TEXT", 8)                    # Specified color (red)
  print("AT 10,20", 10, 20)               # Specified position
  print("BLUE AT 30,30", 30, 30, 12)     # Position and color
  
  # Test 2: Demonstrate cursor behavior
  print("LINE 1")
  print("LINE 2")  # Should appear on next line
  print("LINE 3")
  
  # Test 3: Numbers and mixed content
  score = flr(rnd(9999))
  print("SCORE: #{score}", 10, 50, 10)   # Yellow score
  
  lives = flr(rnd(5)) + 1
  print("LIVES: #{lives}", 10, 58, 11)   # Green lives
  
  # Test 4: All alphabet characters
  alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  print(alphabet, 5, 70, 7)               # White alphabet
  
  # Test 5: Numbers and symbols
  numbers = "0123456789!?:-.="
  print(numbers, 5, 78, 14)               # Pink numbers
  
  # Test 6: Animated text with changing colors
  rainbow_text = "RAINBOW"
  rainbow_text.each_char_with_index do |char, i|
    color_val = (frame // 10 + i) % 16
    print(char.to_s, 20 + i * 4, 90, color_val)
  end
  
  # Test 7: Positioning and return values test
  x, y = print("START", 5, 100, 6)
  print("->", x, y - 6, 8)                # Use return values
  
  # Test 8: Wrapping behavior (long text)
  long_text = "THIS IS A VERY LONG TEXT THAT SHOULD WRAP TO THE NEXT LINE AUTOMATICALLY"
  print(long_text, 5, 110, 13)
end
