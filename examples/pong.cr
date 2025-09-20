require "../src/cgl"

# Game state
player_points = 0
com_points = 0
scored = ""

# Game objects
player = {x: 8.0, y: 63.0, c: 12, w: 2, h: 10, speed: 1.0}
com = {x: 117.0, y: 63.0, c: 8, w: 2, h: 10, speed: 0.75}
ball = {x: 63.0, y: 63.0, c: 7, w: 2, dx: 0.6, dy: 0.0, speed: 1.0, speedup: 0.05}

# Court dimensions
court_left = 0
court_right = 127
court_top = 10
court_bottom = 127

# Center line
line_x = 63
line_y = 10
line_length = 4

_init do
  puts "🏓 PONG - Use arrow keys to move paddle"
  puts "First to score wins!"

  # Initialize ball with original speed (now smooth with sub-pixel rendering)
  ball = {x: 63.0, y: 63.0, c: 7, w: 2, dx: 0.6, dy: (flr(rnd(2)) - 0.5) * 0.6, speed: 1.0, speedup: 0.05}

  # Reset paddles
  player = {x: 8.0, y: 63.0, c: 12, w: 2, h: 10, speed: 1.0}
  com = {x: 117.0, y: 63.0, c: 8, w: 2, h: 10, speed: 0.75}

  # Sound feedback (commented out as requested)
  # if scored == "player"
  #   sfx(3)
  # elsif scored == "com"
  #   sfx(4)
  # else
  #   sfx(5)
  # end
end

_update60 do
  # Player controls - smooth movement
  if btn(2) && player[:y] > court_top + 1 # Up arrow
    player = player.merge({y: player[:y] - player[:speed]})
  end

  if btn(3) && player[:y] + player[:h] < court_bottom - 1 # Down arrow
    player = player.merge({y: player[:y] + player[:speed]})
  end

  # Computer AI
  mid_com = com[:y] + (com[:h] / 2)

  if ball[:dx] > 0
    if mid_com > ball[:y] && com[:y] > court_top + 1
      com = com.merge({y: com[:y] - com[:speed]})
    end
    if mid_com < ball[:y] && com[:y] + com[:h] < court_bottom - 1
      com = com.merge({y: com[:y] + com[:speed]})
    end
  else
    if mid_com > 73
      com = com.merge({y: com[:y] - com[:speed]})
    end
    if mid_com < 53
      com = com.merge({y: com[:y] + com[:speed]})
    end
  end

  # Ball collision with computer paddle - ROBUST AABB collision
  if ball[:dx] > 0 &&
     ball[:x] + ball[:w] >= com[:x] &&
     ball[:x] <= com[:x] + com[:w] &&
     ball[:y] + ball[:w] >= com[:y] &&
     ball[:y] <= com[:y] + com[:h]
    ball = ball.merge({dx: -(ball[:dx] + ball[:speedup])})
    # sfx(0)  # Sound commented out
  end

  # Ball collision with player paddle - ROBUST AABB collision
  if ball[:dx] < 0 &&
     ball[:x] <= player[:x] + player[:w] &&
     ball[:x] + ball[:w] >= player[:x] &&
     ball[:y] + ball[:w] >= player[:y] &&
     ball[:y] <= player[:y] + player[:h]
    # Control ball DY if hit and press up or down
    new_dy = ball[:dy]
    if btn(2) # Up arrow
      if ball[:dy] > 0
        new_dy = -ball[:dy] - ball[:speedup] * 2
      else
        new_dy = ball[:dy] - ball[:speedup] * 2
      end
    end

    if btn(3) # Down arrow
      if ball[:dy] < 0
        new_dy = -ball[:dy] + ball[:speedup] * 2
      else
        new_dy = ball[:dy] + ball[:speedup] * 2
      end
    end

    # Flip ball DX and add speed
    ball = ball.merge({dx: -(ball[:dx] - ball[:speedup]), dy: new_dy})
    # sfx(1)  # Sound commented out
  end

  # Ball collision with court walls
  if ball[:y] + ball[:w] >= court_bottom - 1 || ball[:y] <= court_top + 1
    ball = ball.merge({dy: -ball[:dy]})
    # sfx(2)  # Sound commented out
  end

  # Scoring
  if ball[:x] > court_right
    player_points += 1
    scored = "player"
    # Reset game (call _init logic)
    ball = {x: 63.0, y: 63.0, c: 7, w: 2, dx: 0.6, dy: (flr(rnd(2)) - 0.5) * 0.6, speed: 1.0, speedup: 0.05}
    player = {x: 8.0, y: 63.0, c: 12, w: 2, h: 10, speed: 1.0}
    com = {x: 117.0, y: 63.0, c: 8, w: 2, h: 10, speed: 0.75}
  end

  if ball[:x] < court_left
    com_points += 1
    scored = "com"
    # Reset game
    ball = {x: 63.0, y: 63.0, c: 7, w: 2, dx: -0.6, dy: (flr(rnd(2)) - 0.5) * 0.6, speed: 1.0, speedup: 0.05}
    player = {x: 8.0, y: 63.0, c: 12, w: 2, h: 10, speed: 1.0}
    com = {x: 117.0, y: 63.0, c: 8, w: 2, h: 10, speed: 0.75}
  end

  # Ball movement
  ball = ball.merge({x: ball[:x] + ball[:dx], y: ball[:y] + ball[:dy]})
end

_draw do
  cls() # Clear screen

  # Draw court
  rect(court_left, court_top, court_right, court_bottom, 5)

  # Draw dashed center line
  current_line_y = line_y
  while current_line_y <= court_bottom
    line(line_x, current_line_y, line_x, current_line_y + line_length, 5)
    current_line_y += line_length * 2
  end

  # Draw ball with sub-pixel accuracy using CGL function - NO MORE JITTER!
  rectfill_smooth(
    ball[:x],
    ball[:y],
    ball[:x] + ball[:w],
    ball[:y] + ball[:w],
    ball[:c]
  )

  # Draw player paddle with sub-pixel accuracy using CGL function - SMOOTH!
  rectfill_smooth(
    player[:x],
    player[:y],
    player[:x] + player[:w],
    player[:y] + player[:h],
    player[:c]
  )

  # Draw computer paddle with sub-pixel accuracy using CGL function - SMOOTH!
  rectfill_smooth(
    com[:x],
    com[:y],
    com[:x] + com[:w],
    com[:y] + com[:h],
    com[:c]
  )

  # Draw scores
  print(player_points.to_s, 30, 2, player[:c])
  print(com_points.to_s, 95, 2, com[:c])

  # Show winner
  if player_points >= 5
    print("PLAYER WINS!", 35, 50, 11)
    print("PRESS X TO RESTART", 20, 60, 7)
    if btnp(5) # X button
      player_points = 0
      com_points = 0
    end
  elsif com_points >= 5
    print("COMPUTER WINS!", 30, 50, 8)
    print("PRESS X TO RESTART", 20, 60, 7)
    if btnp(5) # X button
      player_points = 0
      com_points = 0
    end
  end
end
