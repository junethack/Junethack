require 'RMagick'
include Magick
$CGANAMES = %w(black blue green cyan red magenta brown lgray gray lblue lgreen lcyan lred lmagenta yellow white)
 
def cga(cname)
  n = $CGANAMES.index cname
  c = Array.new(3) {|i| n[2-i] * 0xAA + n[3] * 0x55}
  c[1] = 0x55 if n == 6
  return c
end

def write_icon(filename, color, symbol)
  color = cga(color) if color.is_a? String
  r, g, b = *color
  fg = "rgb(#{r>>0},#{g>>0},#{b>>0})"
  bg = "rgb(#{r>>4},#{g>>4},#{b>>4})"

  img = Image.new(50, 50) {self.background_color = bg}
  Draw.new.annotate(img, 0, 0, 0, 0, symbol) {
    self.font_family = 'DejaVu Sans Mono'
    self.fill = fg
    self.pointsize = 40
    self.gravity = CenterGravity
  }
  img.border(2, 2, fg).write("./icons/#{filename}.png")
end

write_icon *$_.split while DATA.gets

__END__
old-ascension lgray <
anti-stoner red x
escapologist brown (
