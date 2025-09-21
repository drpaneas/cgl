require "../src/cgl"

# Crystal structs for game objects - efficient and clean!
struct Player
  property x : Float64, y : Float64, c : Int32, w : Int32, h : Int32, speed : Float64

  def initialize(@x : Float64, @y : Float64, @c : Int32, @w : Int32, @h : Int32, @speed : Float64)
  end
end

struct Ball
  property x : Float64, y : Float64, c : Int32, w : Int32, dx : Float64, dy : Float64, speedup : Float64

  def initialize(@x : Float64, @y : Float64, @c : Int32, @w : Int32, @dx : Float64, @dy : Float64, @speedup : Float64)
  end
end

# Game state
player_points = 0
com_points = 0
scored = ""

# Game objects using efficient structs
player = Player.new(8.0, 63.0, 12, 2, 10, 1.0)
com = Player.new(117.0, 63.0, 8, 2, 10, 0.75)
ball = Ball.new(63.0, 63.0, 7, 2, 0.6, 0.0, 0.05)

# Court dimensions
court_left = 0
court_right = 127
court_top = 10
court_bottom = 127
line_x = 63
line_y = 10
line_length = 4

_init do
  puts "🏓 PONG - Using Crystal Structs (Clean & Efficient)"
  puts "Use arrow keys to move paddle"

  # Initialize ball
  ball.x = 63.0
  ball.y = 63.0
  ball.dx = 0.6
  ball.dy = flr(rnd(2)) - 0.5

  # Reset paddles
  player.x = 8.0
  player.y = 63.0
  com.x = 117.0
  com.y = 63.0
end

_update60 do
  # Player controls - clean struct property access
  if btn(2) && player.y > court_top + 1
    player.y -= player.speed
  end

  if btn(3) && player.y + player.h < court_bottom - 1
    player.y += player.speed
  end

  # Computer AI
  mid_com = com.y + (com.h / 2)

  if ball.dx > 0
    if mid_com > ball.y && com.y > court_top + 1
      com.y -= com.speed
    end
    if mid_com < ball.y && com.y + com.h < court_bottom - 1
      com.y += com.speed
    end
  else
    if mid_com > 73
      com.y -= com.speed
    end
    if mid_com < 53
      com.y += com.speed
    end
  end

  # Ball collision with computer paddle - ROBUST AABB collision
  if ball.dx > 0 &&
     ball.x + ball.w >= com.x &&
     ball.x <= com.x + com.w &&
     ball.y + ball.w >= com.y &&
     ball.y <= com.y + com.h
    ball.dx = -(ball.dx + ball.speedup)
  end

  # Ball collision with player paddle - ROBUST AABB collision
  if ball.dx < 0 &&
     ball.x <= player.x + player.w &&
     ball.x + ball.w >= player.x &&
     ball.y + ball.w >= player.y &&
     ball.y <= player.y + player.h
    # Control ball DY if hit and press up or down
    if btn(2)
      ball.dy = ball.dy > 0 ? -ball.dy - ball.speedup * 2 : ball.dy - ball.speedup * 2
    end
    if btn(3)
      ball.dy = ball.dy < 0 ? -ball.dy + ball.speedup * 2 : ball.dy + ball.speedup * 2
    end

    ball.dx = -(ball.dx - ball.speedup)
  end

  # Ball collision with court walls
  if ball.y + ball.w >= court_bottom - 1 || ball.y <= court_top + 1
    ball.dy = -ball.dy
  end

  # Scoring
  if ball.x > court_right
    player_points += 1
    scored = "player"
    # Reset game
    ball.x = 63.0
    ball.y = 63.0
    ball.dx = 0.6
    ball.dy = flr(rnd(2)) - 0.5
    player.x = 8.0
    player.y = 63.0
    com.x = 117.0
    com.y = 63.0
  end

  if ball.x < court_left
    com_points += 1
    scored = "com"
    # Reset game
    ball.x = 63.0
    ball.y = 63.0
    ball.dx = -0.6
    ball.dy = flr(rnd(2)) - 0.5
    player.x = 8.0
    player.y = 63.0
    com.x = 117.0
    com.y = 63.0
  end

  # Ball movement
  ball.x += ball.dx
  ball.y += ball.dy
end

_draw do
  cls()

  # Draw court
  rect(court_left, court_top, court_right, court_bottom, 5)

  # Draw dashed center line
  current_line_y = line_y
  while current_line_y <= court_bottom
    line(line_x, current_line_y, line_x, current_line_y + line_length, 5)
    current_line_y += line_length * 2
  end

  # Draw all objects using clean struct syntax
  rectfill_smooth(ball.x, ball.y, ball.x + ball.w, ball.y + ball.w, ball.c)
  rectfill_smooth(player.x, player.y, player.x + player.w, player.y + player.h, player.c)
  rectfill_smooth(com.x, com.y, com.x + com.w, com.y + com.h, com.c)

  # Draw scores
  print(player_points.to_s, 30, 2, player.c)
  print(com_points.to_s, 95, 2, com.c)

  # Show winner
  if player_points >= 5
    print("PLAYER WINS!", 35, 50, 11)
    print("PRESS X TO RESTART", 20, 60, 7)
    if btnp(5)
      player_points = 0
      com_points = 0
    end
  elsif com_points >= 5
    print("COMPUTER WINS!", 30, 50, 8)
    print("PRESS X TO RESTART", 20, 60, 7)
    if btnp(5)
      player_points = 0
      com_points = 0
    end
  end
end
