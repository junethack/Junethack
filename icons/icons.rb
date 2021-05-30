#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require_relative 'icons_utils'

def write_icon(filename, color, symbol=nil)
  puts filename

  fg, bg = color_to_rgb(color)
  img = Magick::Image.new(50, 50) {self.background_color = bg}

  y_offset = case symbol
             when '@' then -3
             when 's' then -3
             when '_' then -1
             when '|' then -3
             else           0
             end
  x_offset = case symbol
             when '_' then  1
             when 'Ω' then  1
             else           0
             end
  if symbol
    Magick::Draw.new.annotate(img, 0, 0, x_offset, y_offset, symbol) {
      self.font_family = 'DejaVu Sans Mono'
      self.fill = fg
      self.pointsize = 40
      self.gravity = Magick::CenterGravity
      self.font_weight = Magick::BoldWeight
    }
  end
  img.border(2, 2, fg).write("#{filename}.png")
end

write_icon *$_.split while DATA.gets

__END__
blank_black black
blank_blue blue
blank_green green
blank_cyan cyan
blank_red red
blank_magenta magenta
blank_brown brown
blank_gray gray
blank_yellow yellow
blank_white white
blank_light_gray lgray
blank_light_blue lblue
blank_light_green lgreen
blank_light_cyan lcyan
blank_light_red lred
blank_light_magenta lmagenta
killed_by_molochs_indifference red _
clan-lowest-turns-for-monster-kills gray |
consulted_the_oracle lblue @
entered_the_gnomish_mines brown G
entered_mine_town green @
entered_a_shop yellow @
entered_sokoban lgray 0
entered_a_temple lgray Ω
entered_the_town brown r
entered_fort_ludios yellow $
entered_quest_portal_level magenta ^
entered_moria green o
entered_the_dragon_caves white D
entered_sheol lcyan 8
entered_vlads_tower magenta V
entered_the_blackmarket gray @
never_abused_alignment yellow ±
defeated_grazzt magenta &
defeated_lolth magenta &
defeated_baphomet magenta &
defeated_mephistopheles magenta &
defeated_tiamat magenta D
defeated_kathryn_the_ice_queen lcyan @
defeated_abominable_snowman lcyan Y
defeated_vecna lmagenta L
defeated_kas gray V
