#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'

require_relative 'icons_utils'

def write_icon(text, color, name, number)
  puts name
  21.times {|number|
    filename = "#{name.downcase.gsub(' ', '_')}_#{number+1}.png"

    level = (100*number/20).round
    puts "#{number} #{level}"
    `convert #{text} -modulate #{[level/2+50,100].min},100 #{filename}`

    img = Magick::Image.read(filename).first
    #binding.pry

    # number in the lower right corner
    number_fg, _ = color_to_rgb('white')

    d = Magick::Draw.new
    d.font_family = 'DejaVu Sans Condensed'
    d.pointsize = 9
    d.fill = number_fg

    d.gravity = Magick::SouthEastGravity
    d.annotate(img, 0, 0, 3, 1, (number+1).to_s)

    img.write(filename)
  }
end

write_icon *$_.split(',').map(&:strip) while DATA.gets

__END__
king.png,                 magenta,   ascended_variants, 1
walk_in_the_park.png,     magenta,   sightseeing_tour, 1
backpacking_tourist.png,  magenta,   globetrotter, 1
anti-stoner.png,          magenta,   anti_stoner, 1
