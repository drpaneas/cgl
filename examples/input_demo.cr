require "../src/cgl"

# Player position
player_x = 64
player_y = 64

# Game state
score = 0
messages = [] of String

_init do
  puts "Input demo - Use arrow keys to move, Z/X for actions"
  puts "Arrow keys: Move player"
  puts "Z key: O button (continuous)"
  puts "X key: X button (press once)"
  messages << "GAME STARTED!"
end

_update do
  # Test btn() - continuous button detection
  if btn(0)  # Left
    player_x -= 1
    player_x = 0 if player_x < 0
  end
  
  if btn(1)  # Right
    player_x += 1
    player_x = 127 if player_x > 127
  end
  
  if btn(2)  # Up
    player_y -= 1
    player_y = 0 if player_y < 0
  end
  
  if btn(3)  # Down
    player_y += 1
    player_y = 127 if player_y > 127
  end
  
  # Test btn() - O button (continuous action)
  if btn(4)  # O button (Z key)
    score += 1
  end
  
  # Test btnp() - X button (single press detection)
  if btnp(5)  # X button (X key)
    messages << "X PRESSED! SCORE: #{score}"
    # Keep only last 3 messages
    messages = messages.last(3) if messages.size > 3
  end
end

_draw do
  cls()  # Clear with black
  
  # Draw player as a colored square
  rectfill(player_x - 2, player_y - 2, player_x + 2, player_y + 2, 8)  # Red player
  
  # Draw border around screen
  rect(0, 0, 127, 127, 6)  # Light grey border
  
  # Show input instructions
  print("USE ARROW KEYS TO MOVE", 5, 5, 7)
  print("Z: O BUTTON (HOLD)", 5, 13, 10)
  print("X: X BUTTON (PRESS)", 5, 21, 12)
  
  # Show current button states
  print("BTN STATES:", 5, 35, 6)
  print("LEFT: #{btn(0) ? "ON" : "OFF"}", 5, 43, btn(0) ? 11 : 5)
  print("RIGHT: #{btn(1) ? "ON" : "OFF"}", 5, 51, btn(1) ? 11 : 5)
  print("UP: #{btn(2) ? "ON" : "OFF"}", 5, 59, btn(2) ? 11 : 5)
  print("DOWN: #{btn(3) ? "ON" : "OFF"}", 5, 67, btn(3) ? 11 : 5)
  print("O: #{btn(4) ? "ON" : "OFF"}", 5, 75, btn(4) ? 11 : 5)
  print("X: #{btn(5) ? "ON" : "OFF"}", 5, 83, btn(5) ? 11 : 5)
  
  # Show player position and score
  print("PLAYER: #{player_x},#{player_y}", 5, 95, 14)
  print("SCORE: #{score}", 5, 103, 10)
  
  # Show messages
  messages.each_with_index do |msg, i|
    print(msg, 5, 115 + i * 8, 13)
  end
  
  # Show button press indicators
  if btnp(5)  # Flash when X is pressed
    rectfill(110, 110, 125, 125, 15)  # Peach flash
  end
end
