require 'rubygems'

require File.dirname(__FILE__) + '/../graph.rb'

describe Graph do
  it "should generate an empty graph" do
    g = Graph.new
    g.write("graph_empty.png")
  end

  it "should generate a graph with data" do
    g = Graph.new
    g.add_data_point(1, 1)
    g.add_data_point(2, 2)
    g.add_data_point(3, 3)
    g.write("graph_data.png")
  end

  it "should accept non-string labels" do
    g = Graph.new
    g.add_data_point(1, 1)
    g.write("graph_non_string_label.png")
  end
end
