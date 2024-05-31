#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'

require_relative 'icons_utils'

def write_icon(symbol, color, name, type=nil, small_symbol=nil, small_color=nil, dark=false)
  puts name
  fg, bg = color_to_rgb(color)
  img = Magick::Image.new(50, 50) {self.background_color = bg}
  draw = Magick::Draw.new
  draw.font_family = 'DejaVu Sans Mono'
  draw.gravity = Magick::CenterGravity

  if type == 'rider'
    color, _ = color_to_rgb(small_color, dark)

    img = img.color_floodfill(0,0, 'rgb(13,13,13)')

    block = Proc.new {
      self.fill = color
      self.pointsize = 28
      self.font_weight = Magick::NormalWeight
    }
    draw.annotate(img, 0, 0,  17.75, 0, small_symbol, &block)
    draw.annotate(img, 0, 0, -17.75, 0, small_symbol, &block)
    small_symbol = nil
  end

  if ['leader', 'nemesis'].include?(type)
    img = img.color_floodfill(0,0, 'rgb(5,5,5)')
  end

  # smaller symbol
  if small_symbol && small_symbol.size == 1 && !small_symbol.empty?
    small_fg, _ = color_to_rgb(small_color, dark)
    block = Proc.new {
      self.fill = small_fg
      self.pointsize = 20
      self.font_weight = Magick::NormalWeight
    }

    neuner = ['≋', '≡', '·'].include? small_symbol

    if neuner
      draw.annotate(img, 0, 0, -15, -16, small_symbol, &block)
      draw.annotate(img, 0, 0,   0, -16, small_symbol, &block) if neuner
      draw.annotate(img, 0, 0,  15, -16, small_symbol, &block)

      draw.annotate(img, 0, 0, -15,  -1.5, small_symbol, &block) if neuner
      draw.annotate(img, 0, 0,   0,  -1.5, small_symbol, &block) if neuner
      draw.annotate(img, 0, 0,  15,  -1.5, small_symbol, &block) if neuner

      draw.annotate(img, 0, 0, -15,  14, small_symbol, &block)
      draw.annotate(img, 0, 0,   0,  14, small_symbol, &block) if neuner
      draw.annotate(img, 0, 0,  15,  14, small_symbol, &block)
    elsif ['+', '$'].include? small_symbol
      draw.annotate(img, 0, 0, -18, -16, small_symbol, &block)
      draw.annotate(img, 0, 0,  18, -16, small_symbol, &block)

      draw.annotate(img, 0, 0, -18,  14, small_symbol, &block)
      draw.annotate(img, 0, 0,  18,  14, small_symbol, &block)
    else
      draw.annotate(img, 0, 0, -17, -16, small_symbol, &block)
      draw.annotate(img, 0, 0,  17, -16, small_symbol, &block)

      draw.annotate(img, 0, 0, -17,  15, small_symbol, &block)
      draw.annotate(img, 0, 0,  17,  15, small_symbol, &block)
    end
  end

  # nemesis or leader
  if small_symbol && small_symbol.size == 3 && !small_symbol.empty?
    small_fg, _ = color_to_rgb(small_color, dark)

    d = Magick::Draw.new
    d.font_family = 'DejaVu Sans Condensed'
    d.pointsize = 9
    d.fill = small_fg

    if type == 'leader'
      d.gravity = Magick::NorthWestGravity
      d.annotate(img, 0, 0, 1, 0, small_symbol)
    end
    if name == 'Master of Thieves'
      type = 'nemesis'
      small_symbol = 'Tou'
    end
    if type == 'nemesis'
      d.gravity = Magick::SouthWestGravity
      d.annotate(img, 0, 0, 1, 0, small_symbol)
    end
  end

  y_offset = case symbol
             when '@' then -3
             when 's' then -3
             else           0
             end
  x_offset = ['leader', 'nemesis'].include?(type) ? 0 : 0
  draw.annotate(img, 0, 0, x_offset, y_offset, symbol) {
    self.fill = fg
    self.pointsize = 40
    self.font_weight = Magick::BoldWeight
  }

  img.border(2, 2, fg).write("u-defeated_#{name.downcase.gsub(' ', '_')}.png")
end

write_icon *$_.split(',').map(&:strip) while DATA.gets

__END__
n,  magenta,   Aphrodite           ,      , Ψ, green, dark
V,  magenta,   Vlad the Impaler    ,      , (, yellow
@,  gray,      One-eyed Sam        ,      ,
@,  lblue,     Oracle              ,      , ¶, blue
@,  lgreen,    Medusa              ,      ,
@,  magenta,   Wizard of Yendor    ,      , +, white, dark
@,  magenta,   Croesus             ,      , $, yellow, dark
@,  magenta,   Executioner         ,      , ), lcyan, dark
&,  red,       Durins Bane         ,      , ), brown, dark
;,  magenta,   Watcher in the Water,      , ¶, blue
@,  magenta,   Lord Carnarvon,      leader,  Arc, white
@,  magenta,   Pelias,              leader,  Bar, white
@,  magenta,   Shaman Karnov,       leader,  Cav, white
@,  white,     Robert the Lifer,    leader,  Con, white
@,  magenta,   Hippocrates,         leader,  Hea, white
@,  magenta,   King Arthur,         leader,  Kni, white
@,  gray,      Grand Master,        leader,  Mon, white
@,  white,     Arch Priest,         leader,  Pri, white
@,  magenta,   Orion,               leader,  Ran, white
@,  magenta,   Master of Thieves,   leader,  Rog, white
@,  magenta,   Lord Sato,           leader,  Sam, white
@,  white,     Twoflower,           leader,  Tou, white
@,  magenta,   Norn,                leader,  Val, white
@,  green,     Neferet the Green,   leader,  Wiz, white
&,  red,       Minion of Huhetotl,  nemesis, Arc, white, dark
@,  magenta,   Schliemann,          nemesis, Arc, white, dark
@,  magenta,   Thoth Amon,          nemesis, Bar, white, dark
D,  magenta,   Tiamat,              nemesis, Cav, white, dark
H,  magenta,   Annam,               nemesis, Cav, white, dark
@,  magenta,   Warden Arianna,      nemesis, Con, white, dark
H,  lgray,     Cyclops,             nemesis, Hea, white, dark
D,  red,       Ixoth,               nemesis, Kni, white, dark
@,  magenta,   Master Kaen,         nemesis, Mon, white, dark
&,  red,       Nalzok,              nemesis, Pri, white, dark
s,  magenta,   Scorpius,            nemesis, Ran, white, dark
@,  magenta,   Master Assassin,     nemesis, Rog, white, dark
@,  magenta,   Ashikaga Takauji,    nemesis, Sam, white, dark
H,  magenta,   Lord Surtur,         nemesis, Val, white, dark
@,  gray,      Dark One,            nemesis, Wiz, white, dark
&,  magenta,   Death,               rider,  †, gray
&,  magenta,   Pestilence,          rider,  Ψ, gray
&,  magenta,   Famine,              rider,  %, gray
h,  lgreen,    Cthulhu,                  ,  ≋, red, dark
&,  lgreen,    Juiblex,             dlord,  ≋, blue
&,  magenta,   Yeenoghu,            dlord,  ≡, cyan, dark
&,  magenta,   Orcus,               prince, †, gray
&,  magenta,   Geryon,              prince, Ψ, green, dark
&,  magenta,   Dispater,            prince, Ψ, gray,  dark
&,  magenta,   Baalzebub,           prince, ·, blue
&,  magenta,   Asmodeus,            prince, ·, red
&,  magenta,   Demogorgon,          prince, ≋, red
h,  white,     White Horse,               ,  , white
h,  lgray,     Pale Horse,                ,  , lgray
h,  gray,      Black Horse,               ,  ,  gray
h,  red,       Red Horse,                 ,  , red
