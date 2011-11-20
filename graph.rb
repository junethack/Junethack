require 'gruff'

class Graph

  OUTPUT_DIRECTORY = 'public/tmp/'

  def initialize(width=400)
    @g = Gruff::Line.new(width)
    @g.hide_legend = true
    @g.hide_title = true
    @data = []
    @g.labels = {}

    Dir.mkdir(OUTPUT_DIRECTORY) unless File.exists?(OUTPUT_DIRECTORY)
  end

  def add_data_point(x, y)
    @g.labels[@g.labels.size] = x.to_s
    @data << y
  end

  def write(filename)
    @g.data('data', @data)
    # the graph should start at 0
if false then
    @g.minimum_value = 0
    # set in case of no data
    @g.maximum_value ||= 0

    if @g.maximum_value < 20 then
      @g.y_axis_increment = 1
      @g.maximum_value = 12
    elsif @g.maximum_value < 100 then
      @g.y_axis_increment = 10
    elsif @g.maximum_value < 500 then
      @g.y_axis_increment = 50
      @g.maximum_value = 400
    elsif @g.maximum_value < 1000 then
      @g.y_axis_increment = 100
    end
end

    @g.write(OUTPUT_DIRECTORY+filename)
  end

end

