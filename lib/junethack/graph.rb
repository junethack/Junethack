require 'csv'
require 'date'

class Graph

  OUTPUT_DIRECTORY = 'public/tmp/'

  def initialize(width=400)
    @data = []

    Dir.mkdir(OUTPUT_DIRECTORY) unless File.exists?(OUTPUT_DIRECTORY)
  end

  def add_data_point(x, y)
    # replace nil values with zero
    @data << (y ? y : 0)
  end

  def write(filename)
    # write date points into CSV
    CSV.open(OUTPUT_DIRECTORY+filename+".csv", "w") do |csv|
      csv << @data
    end
  end

end

