require "../src/cgl"

# Game state
player_points = 0
com_points = 0
scored = ""

# Game objects - using mutable variables instead of hash merging
player_x = 8.0
player_y = 63.0
player_c = 12
player_w = 2
player_h = 10
player_speed = 1.0

com_x = 117.0
com_y = 63.0
com_c = 8
com_w = 2
com_h = 10
com_speed = 0.75

ball_x = 63.0
ball_y = 63.0
ball_c = 7
ball_w = 2
ball_dx = 0.6
ball_dy = 0.0
ball_speed = 1.0
ball_speedup = 0.05

# Court dimensions
court_left = 0
court_right = 127
court_top = 10
court_bottom = 127
line_x = 63
line_y = 10
line_length = 4

_init do
  puts "🏓 PONG - Memory Leak Fixed Version"
  puts "Using mutable variables instead of hash merging"

  # Initialize ball
  ball_x = 63.0
  ball_y = 63.0
  ball_dx = 0.6
  ball_dy = flr(rnd(2)) - 0.5

  # Reset paddles
  player_x = 8.0
  player_y = 63.0
  com_x = 117.0
  com_y = 63.0
end

_update60 do
  # Player controls - direct variable modification (no new objects!)
  if btn(2) && player_y > court_top + 1
    player_y -= player_speed
  end

  if btn(3) && player_y + player_h < court_bottom - 1
    player_y += player_speed
  end

  # Computer AI - direct variable modification
  mid_com = com_y + (com_h / 2)

  if ball_dx > 0
    if mid_com > ball_y && com_y > court_top + 1
      com_y -= com_speed
    end
    if mid_com < ball_y && com_y + com_h < court_bottom - 1
      com_y += com_speed
    end
  else
    if mid_com > 73
      com_y -= com_speed
    end
    if mid_com < 53
      com_y += com_speed
    end
  end

  # Ball collision with computer paddle - ROBUST AABB collision
  if ball_dx > 0 &&
     ball_x + ball_w >= com_x &&
     ball_x <= com_x + com_w &&
     ball_y + ball_w >= com_y &&
     ball_y <= com_y + com_h
    ball_dx = -(ball_dx + ball_speedup)
  end

  # Ball collision with player paddle - ROBUST AABB collision
  if ball_dx < 0 &&
     ball_x <= player_x + player_w &&
     ball_x + ball_w >= player_x &&
     ball_y + ball_w >= player_y &&
     ball_y <= player_y + player_h
    # Control ball DY if hit and press up or down
    if btn(2)
      ball_dy = ball_dy > 0 ? -ball_dy - ball_speedup * 2 : ball_dy - ball_speedup * 2
    end
    if btn(3)
      ball_dy = ball_dy < 0 ? -ball_dy + ball_speedup * 2 : ball_dy + ball_speedup * 2
    end

    ball_dx = -(ball_dx - ball_speedup)
  end

  # Ball collision with court walls
  if ball_y + ball_w >= court_bottom - 1 || ball_y <= court_top + 1
    ball_dy = -ball_dy
  end

  # Scoring
  if ball_x > court_right
    player_points += 1
    scored = "player"
    # Reset game - direct variable assignment
    ball_x = 63.0
    ball_y = 63.0
    ball_dx = 0.6
    ball_dy = flr(rnd(2)) - 0.5
    player_x = 8.0
    player_y = 63.0
    com_x = 117.0
    com_y = 63.0
  end

  if ball_x < court_left
    com_points += 1
    scored = "com"
    # Reset game - direct variable assignment
    ball_x = 63.0
    ball_y = 63.0
    ball_dx = -0.6
    ball_dy = flr(rnd(2)) - 0.5
    player_x = 8.0
    player_y = 63.0
    com_x = 117.0
    com_y = 63.0
  end

  # Ball movement - direct variable modification
  ball_x += ball_dx
  ball_y += ball_dy
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

  # Draw ball with sub-pixel accuracy - NO MEMORY ALLOCATION!
  rectfill_smooth(ball_x, ball_y, ball_x + ball_w, ball_y + ball_w, ball_c)

  # Draw player paddle with sub-pixel accuracy - NO MEMORY ALLOCATION!
  rectfill_smooth(player_x, player_y, player_x + player_w, player_y + player_h, player_c)

  # Draw computer paddle with sub-pixel accuracy - NO MEMORY ALLOCATION!
  rectfill_smooth(com_x, com_y, com_x + com_w, com_y + com_h, com_c)

  # Draw scores
  print(player_points.to_s, 30, 2, player_c)
  print(com_points.to_s, 95, 2, com_c)

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
