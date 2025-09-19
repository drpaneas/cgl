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

  @[AlwaysInline]
  def self.color(index)
    # Branchless clamp: index & 15 is faster than index.clamp(0, 15)
    COLORS.unsafe_fetch(index & 15)
  end

  def self.init_window(title = "CGL", scale = 4)
    return if @@initialized
    Raylib.init_window(128 * scale, 128 * scale, title)
    Raylib.set_target_fps(60)
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
