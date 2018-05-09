#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'

require 'rmagick'
include Magick
$CGANAMES = %w(black blue green cyan red magenta brown lgray gray lblue lgreen lcyan lred lmagenta yellow white)
def cga(cname)
  n = $CGANAMES.index cname
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

def write_icon(symbol, color, name, type=nil, small_symbol=nil, small_color=nil, dark=false)
  puts name
  fg, bg = color_to_rgb(color)
  img = Image.new(50, 50) {self.background_color = bg}
  draw = Draw.new
  draw.font_family = 'DejaVu Sans Mono'
  draw.gravity = CenterGravity

  if type == 'rider'
    color, _ = color_to_rgb(small_color, dark)

    img = img.color_floodfill(0,0, 'rgb(15,15,15)')

    block = Proc.new {
      self.fill = color
      self.pointsize = 28
    }
    draw.annotate(img, 0, 0,  17.75, 0, small_symbol, &block)
    draw.annotate(img, 0, 0, -17.75, 0, small_symbol, &block)
    small_symbol = nil
  end

  # smaller symbol

  if small_symbol && !small_symbol.empty?
    small_fg, _ = color_to_rgb(small_color, dark)
    block = Proc.new {
      self.fill = small_fg
      self.pointsize = 20
    }

    neuner = ['≋', '≡', '·'].include? small_symbol

    draw.annotate(img, 0, 0, -15, -16, small_symbol, &block)
    draw.annotate(img, 0, 0,   0, -16, small_symbol, &block) if neuner
    draw.annotate(img, 0, 0,  15, -16, small_symbol, &block)

    draw.annotate(img, 0, 0, -15,  -1.5, small_symbol, &block) if neuner
    draw.annotate(img, 0, 0,   0,  -1.5, small_symbol, &block) if neuner
    draw.annotate(img, 0, 0,  15,  -1.5, small_symbol, &block) if neuner

    draw.annotate(img, 0, 0, -15,  14, small_symbol, &block)
    draw.annotate(img, 0, 0,   0,  14, small_symbol, &block) if neuner
    draw.annotate(img, 0, 0,  15,  14, small_symbol, &block)
  end

  draw.annotate(img, 0, 0, 0, 0, symbol) {
    self.fill = fg
    self.pointsize = 40
  }

  img.border(2, 2, fg).write("#{name.downcase}.png")
end

write_icon *$_.split(',').map(&:strip) while DATA.gets

__END__
&,  magenta,   Death,               rider,  †, gray
&,  magenta,   Pestilence,          rider,  Ψ, gray
&,  magenta,   Famine,              rider,  %, gray
h,  lgreen,    Cthulhu,                  ,  ≋, red, dark
&,  lgreen,    Juiblex,             dlord,  ≋, blue
&,  magenta,   Yeenoghu,            dlord,  ≡, lcyan, dark
&,  magenta,   Orcus,               prince, †, gray
&,  magenta,   Geryon,              prince, Ψ, green, dark
&,  magenta,   Dispater,            prince, Ψ, gray,  dark
&,  magenta,   Baalzebub,           prince, ·, blue
&,  magenta,   Asmodeus,            prince, ·, red
&,  magenta,   Demogorgon,          prince, ≋, red
