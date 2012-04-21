require 'gruff'
require 'fastercsv'
require 'date'

class Graph

  OUTPUT_DIRECTORY = 'public/tmp/'

  def initialize(width=400)
    @g = Gruff::Line.new(width)
    @g.hide_legend = true
    @g.hide_title = true
    @data = []
    @g.labels = {}
    @g.theme_greyscale

    Dir.mkdir(OUTPUT_DIRECTORY) unless File.exists?(OUTPUT_DIRECTORY)
  end

  def add_data_point(x, y)
    @g.labels[@g.labels.size] = x.to_s
puts y
puts y.class
    # replace nil values with zero
    @data << (y ? y : 0)
  end

  def write(filename)
    @g.data('data', @data)
    # the graph should start at 0
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

    #puts @g.labels.values.sort.map {|d| Time.parse(d).to_i}.join ','
    #puts @data.join ','
    FasterCSV.open(OUTPUT_DIRECTORY+filename+".csv", "w") do |csv|
      #csv << @g.labels.values.sort.map {
      #csv << (@g.labels.values.sort.map {|t| Time.parse(t).to_i}).join(',')
      #csv << @g.labels.values.sort.map {|t| Time.parse(t).to_i}
      csv << @data
    end

    @g.write(OUTPUT_DIRECTORY+filename+".png")
  end

end

