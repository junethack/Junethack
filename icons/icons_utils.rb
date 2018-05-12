require 'rmagick'

$CGANAMES = %w(black blue green cyan red magenta brown lgray gray lblue lgreen lcyan lred lmagenta yellow white)
def cga(cname)
  n = $CGANAMES.index cname.to_s
  c = Array.new(3) {|i| n[2-i] * 0xAA + n[3] * 0x55}
  c[1] = 0x55 if n == 6
  c = [30, 30, 255] if cname == "blue"
  return c
end

def color_to_rgb(color, dark=false)
  color = cga(color)
  color = color.map {|c| c / 4 * 3 } if dark
  r, g, b = *color
  fg = "rgb(#{r>>0},#{g>>0},#{b>>0})"
  bg = "rgb(#{r>>4},#{g>>4},#{b>>4})"
  [fg, bg]
end

def setup_image(color)
  _, bg = color_to_rgb(color)
  Magick::Image.new(50, 50) { self.background_color = bg}
end

def write_image(image, color, name)
  fg, _ = color_to_rgb(color)
  image.border(2, 2, fg).write("#{name.downcase.gsub(' ', '_')}.png")
end

def draw_text(image, text, color, size, x=0, y=0, bold: false)
  fg, _ = color_to_rgb(color)

  draw = Magick::Draw.new
  draw.font_family = 'DejaVu Sans Mono'
  draw.gravity = Magick::CenterGravity
  draw.fill = fg
  draw.pointsize = size
  draw.font_weight = bold ?  Magick::BoldWeight : Magick::NormalWeight

  draw.annotate(image, 0, 0, x, y, text)
end
