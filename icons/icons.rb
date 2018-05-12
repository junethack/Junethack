#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require_relative 'icons_utils'

def write_icon(filename, color, symbol)
  puts filename

  fg, bg = color_to_rgb(color)
  img = Magick::Image.new(50, 50) {self.background_color = bg}

  y_offset = case symbol
             when '@' then -3
             when 's' then -3
             else           0
             end
 #Magick::Draw.new.annotate(img, 0, 0, 0, y_offset, symbol) {
 #  self.font_family = 'DejaVu Sans Mono'
 #  self.fill = fg
 #  self.pointsize = 40
 #  self.gravity = Magick::CenterGravity
 #  self.font_weight = Magick::BoldWeight
 #}
  img.border(2, 2, fg).write("#{filename}.png")
end

write_icon *$_.split while DATA.gets

__END__
blank_black black X
blank_blue blue X
blank_green green X
blank_cyan cyan X
blank_red red X
blank_magenta magenta X
blank_brown brown X
blank_gray gray X
blank_yellow yellow X
blank_white white X
blank_light_gray lgray X
blank_light_blue lblue X
blank_light_green lgreen X
blank_light_cyan lcyan X
blank_light_red lred X
blank_light_magenta lmagenta X
