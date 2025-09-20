require "raylib-cr"

# Pre-allocated PICO-8 colors (zero runtime allocation)
COLORS = StaticArray[
  Raylib::Color.new(r: 0_u8, g: 0_u8, b: 0_u8, a: 255_u8),
  Raylib::Color.new(r: 29_u8, g: 43_u8, b: 83_u8, a: 255_u8),
  Raylib::Color.new(r: 126_u8, g: 37_u8, b: 83_u8, a: 255_u8),
  Raylib::Color.new(r: 0_u8, g: 135_u8, b: 81_u8, a: 255_u8),
  Raylib::Color.new(r: 171_u8, g: 82_u8, b: 54_u8, a: 255_u8),
  Raylib::Color.new(r: 95_u8, g: 87_u8, b: 79_u8, a: 255_u8),
  Raylib::Color.new(r: 194_u8, g: 195_u8, b: 199_u8, a: 255_u8),
  Raylib::Color.new(r: 255_u8, g: 241_u8, b: 232_u8, a: 255_u8),
  Raylib::Color.new(r: 255_u8, g: 0_u8, b: 77_u8, a: 255_u8),
  Raylib::Color.new(r: 255_u8, g: 163_u8, b: 0_u8, a: 255_u8),
  Raylib::Color.new(r: 255_u8, g: 236_u8, b: 39_u8, a: 255_u8),
  Raylib::Color.new(r: 0_u8, g: 228_u8, b: 54_u8, a: 255_u8),
  Raylib::Color.new(r: 41_u8, g: 173_u8, b: 255_u8, a: 255_u8),
  Raylib::Color.new(r: 131_u8, g: 118_u8, b: 156_u8, a: 255_u8),
  Raylib::Color.new(r: 255_u8, g: 119_u8, b: 168_u8, a: 255_u8),
  Raylib::Color.new(r: 255_u8, g: 204_u8, b: 170_u8, a: 255_u8),
]

module CGL
  @@cursor_x = 0_i32
  @@cursor_y = 0_i32
  @@draw_color = 6_i32 # Default to light grey (PICO-8 default)
  @@scale = 4_i32      # Default scale factor
  @@init_func : Proc(Nil) | Nil = nil
  @@update_func : Proc(Nil) | Nil = nil
  @@draw_func : Proc(Nil) | Nil = nil
  @@auto_run = true
  @@initialized = false

  def self.cursor_x
    @@cursor_x
  end

  def self.cursor_y
    @@cursor_y
  end

  def self.set_cursor(x, y)
    @@cursor_x = x; @@cursor_y = y
  end

  def self.draw_color
    @@draw_color
  end

  def self.set_draw_color(col)
    @@draw_color = col & 15 # Clamp to 0-15
  end

  @[AlwaysInline]
  def self.color(index)
    # Branchless clamp: index & 15 is faster than index.clamp(0, 15)
    COLORS.unsafe_fetch(index & 15)
  end

  def self.init_window(title = "CGL", scale = 4)
    return if @@initialized
    @@scale = scale
    Raylib.init_window(128 * scale, 128 * scale, title)
    Raylib.set_target_fps(30) # PICO-8 default is 30 FPS
    @@initialized = true
  end

  def self.close_window
    return unless @@initialized
    Raylib.close_window
    @@initialized = false
  end

  def self.check_auto_run
    if @@auto_run && @@init_func && @@update_func && @@draw_func
      @@auto_run = false
      at_exit {
        init_window
        @@init_func.not_nil!.call
        while !Raylib.close_window?
          Raylib.begin_drawing
          @@update_func.not_nil!.call
          @@draw_func.not_nil!.call
          Raylib.end_drawing
        end
        close_window
      }
    end
  end

  def self.set_init(&block)
    @@init_func = block; check_auto_run
  end

  def self.set_update(&block)
    @@update_func = block; check_auto_run
  end

  def self.set_draw(&block)
    @@draw_func = block; check_auto_run
  end

  @[AlwaysInline]
  def self.pset(x, y, col = nil)
    # Use provided color or current draw color
    if col.nil?
      pixel_color = @@draw_color
    else
      pixel_color = col & 15
      # Update draw color if color was provided (PICO-8 behavior)
      @@draw_color = pixel_color
    end
    # Draw scaled pixel - use bit shifting for 4x scale (x << 2 == x * 4)
    Raylib.draw_rectangle(x << 2, y << 2, @@scale, @@scale, COLORS.unsafe_fetch(pixel_color))
  end

  # Optimized Bresenham's line algorithm for PICO-8
  def self.line(x0, y0, x1, y1, col = nil)
    # Handle color parameter like pset
    if col.nil?
      line_color = @@draw_color
    else
      line_color = col & 15
      @@draw_color = line_color
    end

    # Pre-fetch color to avoid repeated lookups
    pixel_color = COLORS.unsafe_fetch(line_color)

    # Optimized Bresenham's line algorithm
    dx = (x1 - x0).abs
    dy = (y1 - y0).abs
    sx = x0 < x1 ? 1 : -1
    sy = y0 < y1 ? 1 : -1
    err = dx - dy

    x = x0
    y = y0

    loop do
      # Draw pixel at current position - optimized with pre-shifted coordinates
      Raylib.draw_rectangle(x << 2, y << 2, @@scale, @@scale, pixel_color)

      # Check if we've reached the end point
      break if x == x1 && y == y1

      # Calculate next position - optimized with single calculation
      e2 = err << 1 # Equivalent to 2 * err but faster
      if e2 > -dy
        err -= dy
        x += sx
      end
      if e2 < dx
        err += dx
        y += sy
      end
    end
  end

  # ULTIMATE OPTIMIZED rectangle outline - 4 GPU calls, fastest possible
  @[AlwaysInline]
  def self.rect(x0, y0, x1, y1, col = nil)
    # Branchless color handling and coordinate normalization
    rect_color = col.nil? ? @@draw_color : (col & 15).tap { |c| @@draw_color = c }
    min_x, max_x = x0 < x1 ? {x0, x1} : {x1, x0}
    min_y, max_y = y0 < y1 ? {y0, y1} : {y1, y0}

    pixel_color = COLORS.unsafe_fetch(rect_color)
    width = (max_x - min_x + 1) << 2 # Bit shift for maximum speed
    height = (max_y - min_y + 1) << 2

    # 4 optimized GPU calls for outline - MAXIMUM SPEED
    Raylib.draw_rectangle(min_x << 2, min_y << 2, width, @@scale, pixel_color) # Top
    Raylib.draw_rectangle(min_x << 2, max_y << 2, width, @@scale, pixel_color) # Bottom
    if max_y > min_y + 1
      edge_height = (max_y - min_y - 1) << 2                                                 # Bit shift optimization
      Raylib.draw_rectangle(min_x << 2, (min_y + 1) << 2, @@scale, edge_height, pixel_color) # Left
      Raylib.draw_rectangle(max_x << 2, (min_y + 1) << 2, @@scale, edge_height, pixel_color) # Right
    end
  end

  # ULTIMATE OPTIMIZED filled rectangle - single GPU call, fastest possible
  @[AlwaysInline]
  def self.rectfill(x0, y0, x1, y1, col = nil)
    # Branchless color handling and coordinate normalization
    rect_color = col.nil? ? @@draw_color : (col & 15).tap { |c| @@draw_color = c }
    min_x, max_x = x0 < x1 ? {x0, x1} : {x1, x0}
    min_y, max_y = y0 < y1 ? {y0, y1} : {y1, y0}

    # Single GPU call with pre-computed dimensions - MAXIMUM SPEED
    width = (max_x - min_x + 1) << 2 # Bit shift instead of multiplication
    height = (max_y - min_y + 1) << 2
    Raylib.draw_rectangle(min_x << 2, min_y << 2, width, height, COLORS.unsafe_fetch(rect_color))
  end

  # Math functions - PICO-8 compatible
  @[AlwaysInline]
  def self.flr(a)
    a.floor.to_i32
  end

  @[AlwaysInline]
  def self.rnd(limit = 1.0)
    Random.rand(limit.to_f64)
  end

  # Text rendering - simplified PICO-8 font (4x6 pixels per character)
  def self.print_char(char, x, y, col)
    # Simple 4x6 font patterns for basic ASCII
    pattern = case char
              when 'A', 'a' then [0b0110, 0b1001, 0b1111, 0b1001, 0b1001, 0b0000]
              when 'B', 'b' then [0b1110, 0b1001, 0b1110, 0b1001, 0b1110, 0b0000]
              when 'C', 'c' then [0b0111, 0b1000, 0b1000, 0b1000, 0b0111, 0b0000]
              when 'D', 'd' then [0b1110, 0b1001, 0b1001, 0b1001, 0b1110, 0b0000]
              when 'E', 'e' then [0b1111, 0b1000, 0b1110, 0b1000, 0b1111, 0b0000]
              when 'F', 'f' then [0b1111, 0b1000, 0b1110, 0b1000, 0b1000, 0b0000]
              when 'G', 'g' then [0b0111, 0b1000, 0b1011, 0b1001, 0b0111, 0b0000]
              when 'H', 'h' then [0b1001, 0b1001, 0b1111, 0b1001, 0b1001, 0b0000]
              when 'I', 'i' then [0b0111, 0b0010, 0b0010, 0b0010, 0b0111, 0b0000]
              when 'J', 'j' then [0b0111, 0b0001, 0b0001, 0b1001, 0b0110, 0b0000]
              when 'K', 'k' then [0b1001, 0b1010, 0b1100, 0b1010, 0b1001, 0b0000]
              when 'L', 'l' then [0b1000, 0b1000, 0b1000, 0b1000, 0b1111, 0b0000]
              when 'M', 'm' then [0b1001, 0b1111, 0b1111, 0b1001, 0b1001, 0b0000]
              when 'N', 'n' then [0b1001, 0b1101, 0b1111, 0b1011, 0b1001, 0b0000]
              when 'O', 'o' then [0b0110, 0b1001, 0b1001, 0b1001, 0b0110, 0b0000]
              when 'P', 'p' then [0b1110, 0b1001, 0b1110, 0b1000, 0b1000, 0b0000]
              when 'Q', 'q' then [0b0110, 0b1001, 0b1001, 0b1011, 0b0111, 0b0000]
              when 'R', 'r' then [0b1110, 0b1001, 0b1110, 0b1010, 0b1001, 0b0000]
              when 'S', 's' then [0b0111, 0b1000, 0b0110, 0b0001, 0b1110, 0b0000]
              when 'T', 't' then [0b1111, 0b0010, 0b0010, 0b0010, 0b0010, 0b0000]
              when 'U', 'u' then [0b1001, 0b1001, 0b1001, 0b1001, 0b0110, 0b0000]
              when 'V', 'v' then [0b1001, 0b1001, 0b1001, 0b0110, 0b0110, 0b0000]
              when 'W', 'w' then [0b1001, 0b1001, 0b1111, 0b1111, 0b1001, 0b0000]
              when 'X', 'x' then [0b1001, 0b0110, 0b0110, 0b0110, 0b1001, 0b0000]
              when 'Y', 'y' then [0b1001, 0b1001, 0b0110, 0b0010, 0b0010, 0b0000]
              when 'Z', 'z' then [0b1111, 0b0001, 0b0110, 0b1000, 0b1111, 0b0000]
              when '0'      then [0b0110, 0b1001, 0b1001, 0b1001, 0b0110, 0b0000]
              when '1'      then [0b0010, 0b0110, 0b0010, 0b0010, 0b0111, 0b0000]
              when '2'      then [0b0110, 0b1001, 0b0010, 0b0100, 0b1111, 0b0000]
              when '3'      then [0b1111, 0b0010, 0b0110, 0b0001, 0b1110, 0b0000]
              when '4'      then [0b0010, 0b0110, 0b1010, 0b1111, 0b0010, 0b0000]
              when '5'      then [0b1111, 0b1000, 0b1110, 0b0001, 0b1110, 0b0000]
              when '6'      then [0b0110, 0b1000, 0b1110, 0b1001, 0b0110, 0b0000]
              when '7'      then [0b1111, 0b0001, 0b0010, 0b0100, 0b1000, 0b0000]
              when '8'      then [0b0110, 0b1001, 0b0110, 0b1001, 0b0110, 0b0000]
              when '9'      then [0b0110, 0b1001, 0b0111, 0b0001, 0b0110, 0b0000]
              when ' '      then [0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000]
              when '.'      then [0b0000, 0b0000, 0b0000, 0b0000, 0b0010, 0b0000]
              when ','      then [0b0000, 0b0000, 0b0000, 0b0010, 0b0100, 0b0000]
              when '!'      then [0b0010, 0b0010, 0b0010, 0b0000, 0b0010, 0b0000]
              when '?'      then [0b0110, 0b1001, 0b0010, 0b0000, 0b0010, 0b0000]
              when ':'      then [0b0000, 0b0010, 0b0000, 0b0010, 0b0000, 0b0000]
              when '-'      then [0b0000, 0b0000, 0b1111, 0b0000, 0b0000, 0b0000]
              when '='      then [0b0000, 0b1111, 0b0000, 0b1111, 0b0000, 0b0000]
              else               [0b1111, 0b1001, 0b1001, 0b1001, 0b1111, 0b0000] # Default box
              end

    # Draw character using pattern
    6.times do |row|
      4.times do |bit_col|
        if (pattern[row] >> (3 - bit_col)) & 1 == 1
          pset(x + bit_col, y + row, col)
        end
      end
    end
  end

  # PICO-8 print function with flexible parameters
  def self.print(text, x = nil, y = nil, col = nil)
    # Handle PICO-8's flexible parameter behavior
    if x.nil? && y.nil? && col.nil?
      # print("text") - use cursor position and current color
      print_x, print_y, print_col = @@cursor_x, @@cursor_y, @@draw_color
    elsif y.nil? && col.nil? && x.is_a?(Int32)
      # print("text", color) - use cursor position with specified color
      print_x, print_y, print_col = @@cursor_x, @@cursor_y, x & 15
    elsif col.nil? && x.is_a?(Int32) && y.is_a?(Int32)
      # print("text", x, y) - use specified position with current color
      print_x, print_y, print_col = x, y, @@draw_color
    elsif x.is_a?(Int32) && y.is_a?(Int32) && col.is_a?(Int32)
      # print("text", x, y, color) - use specified position and color
      print_x, print_y, print_col = x, y, col & 15
    else
      # Default fallback
      print_x, print_y, print_col = @@cursor_x, @@cursor_y, @@draw_color
    end

    # Update draw color
    @@draw_color = print_col

    # Draw each character
    current_x = print_x
    current_y = print_y
    text.to_s.each_char do |char|
      if char == '\n'
        # Newline: move to next line
        current_x = 0
        current_y += 6
      else
        # Draw character and advance cursor
        print_char(char, current_x, current_y, print_col)
        current_x += 4
      end

      # Wrap to next line if we exceed screen width
      if current_x >= 128
        current_x = 0
        current_y += 6
      end
    end

    # Update cursor position and return final position (PICO-8 behavior)
    @@cursor_x = current_x
    @@cursor_y = current_y
    {current_x, current_y} # Return cursor position
  end
end

def _init(&block)
  CGL.set_init(&block)
end

def _update(&block)
  CGL.set_update(&block)
end

def _draw(&block)
  CGL.set_draw(&block)
end

@[AlwaysInline]
def cls(col = 0)
  CGL.set_cursor(0, 0)
  Raylib.clear_background(CGL.color(col))
end

def pset(x, y, col = nil)
  CGL.pset(x, y, col)
end

def line(x0, y0, x1, y1, col = nil)
  CGL.line(x0, y0, x1, y1, col)
end

def rect(x0, y0, x1, y1, col = nil)
  CGL.rect(x0, y0, x1, y1, col)
end

def rectfill(x0, y0, x1, y1, col = nil)
  CGL.rectfill(x0, y0, x1, y1, col)
end

def color(col)
  CGL.set_draw_color(col)
end

def flr(a)
  CGL.flr(a)
end

def rnd(limit = 1.0)
  CGL.rnd(limit)
end

def print(text, x = nil, y = nil, col = nil)
  CGL.print(text, x, y, col)
end
