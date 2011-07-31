require 'normalize_death'

# Game mock object
class Game
  attr_accessor :death
end

describe Game,"normalization of death strings" do
  before(:all) do
    @game = Game.new
  end

  it "should not change simple ascended/quit/escaped" do
    ["ascended", "quit", "escaped"].each do |death|
      @game.death = death
      @game.normalize_death.should == @game.death
    end
  end

  it "should not change NetHack 1.3d deaths" do
    # NetHack 1.3d "ascension" message
    @game.death = "escaped (with amulet)"
    @game.normalize_death.should == @game.death
  end
end
