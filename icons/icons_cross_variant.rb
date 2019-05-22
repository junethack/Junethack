#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'

require_relative 'icons_utils'

def write_icon(text, color, name, number)
  puts name
  fg, bg = color_to_rgb(color)
  img = Magick::Image.new(50, 50) {self.background_color = bg}
  draw = Magick::Draw.new
  draw.font_family = 'DejaVu Sans Mono'
  draw.gravity = Magick::CenterGravity

  # number in the lower right corner
  number_fg, _ = color_to_rgb('white')

  d = Magick::Draw.new
  d.font_family = 'DejaVu Sans Condensed'
  d.pointsize = 9
  d.fill = number_fg

  d.gravity = Magick::SouthEastGravity
  d.annotate(img, 0, 0, 1, 0, number)

  draw.annotate(img, 0, 0, 0, 0, text) {
    self.fill = fg
    self.pointsize = 24
    self.font_weight = Magick::BoldWeight
  }

  img.border(2, 2, fg).write("#{name.downcase.gsub(' ', '_')}_#{number}.png")
end

write_icon *$_.split(',').map(&:strip) while DATA.gets

__END__
tmp,  magenta,   ascended_variants, 1
tmp,  magenta,   ascended_variants, 2
tmp,  magenta,   ascended_variants, 3
tmp,  magenta,   ascended_variants, 4
tmp,  magenta,   ascended_variants, 5
tmp,  magenta,   ascended_variants, 6
tmp,  magenta,   ascended_variants, 7
tmp,  magenta,   ascended_variants, 8
tmp,  magenta,   ascended_variants, 9
tmp,  magenta,   ascended_variants, 10
tmp,  magenta,   ascended_variants, 11
tmp,  magenta,   ascended_variants, 12
tmp,  magenta,   ascended_variants, 13
tmp,  magenta,   ascended_variants, 14
tmp,  magenta,   ascended_variants, 15
tmp,  magenta,   ascended_variants, 16
tmp,  red,   anti_stoner, 1
tmp,  red,   anti_stoner, 2
tmp,  red,   anti_stoner, 3
tmp,  red,   anti_stoner, 4
tmp,  red,   anti_stoner, 5
tmp,  red,   anti_stoner, 6
tmp,  red,   anti_stoner, 7
tmp,  red,   anti_stoner, 8
tmp,  red,   anti_stoner, 9
tmp,  red,   anti_stoner, 10
tmp,  red,   anti_stoner, 11
tmp,  red,   anti_stoner, 12
tmp,  red,   anti_stoner, 13
tmp,  red,   anti_stoner, 14
tmp,  red,   anti_stoner, 15
tmp,  red,   anti_stoner, 16
tmp,  cyan,   globetrotter, 1
tmp,  cyan,   globetrotter, 2
tmp,  cyan,   globetrotter, 3
tmp,  cyan,   globetrotter, 4
tmp,  cyan,   globetrotter, 5
tmp,  cyan,   globetrotter, 6
tmp,  cyan,   globetrotter, 7
tmp,  cyan,   globetrotter, 8
tmp,  cyan,   globetrotter, 9
tmp,  cyan,   globetrotter, 10
tmp,  cyan,   globetrotter, 11
tmp,  cyan,   globetrotter, 12
tmp,  cyan,   globetrotter, 13
tmp,  cyan,   globetrotter, 14
tmp,  cyan,   globetrotter, 15
tmp,  cyan,   globetrotter, 16
tmp,  lgray,   sightseeing_tour, 1
tmp,  lgray,   sightseeing_tour, 2
tmp,  lgray,   sightseeing_tour, 3
tmp,  lgray,   sightseeing_tour, 4
tmp,  lgray,   sightseeing_tour, 5
tmp,  lgray,   sightseeing_tour, 6
tmp,  lgray,   sightseeing_tour, 7
tmp,  lgray,   sightseeing_tour, 8
tmp,  lgray,   sightseeing_tour, 9
tmp,  lgray,   sightseeing_tour, 10
tmp,  lgray,   sightseeing_tour, 11
tmp,  lgray,   sightseeing_tour, 12
tmp,  lgray,   sightseeing_tour, 13
tmp,  lgray,   sightseeing_tour, 14
tmp,  lgray,   sightseeing_tour, 15
tmp,  lgray,   sightseeing_tour, 16
