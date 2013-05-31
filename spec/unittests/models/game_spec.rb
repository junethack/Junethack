require 'spec_helper'

require 'trophyscore'
require 'userscore'

describe Game do
  it "should remove the version info from variants that often change their version number" do
    Game.new(:version => 'UNH-4.1.1',
             :user_id => 1,
             :server_id => 1,
             :death => 'ascended').save!

    Game.first(:version => 'UNH-4.1.1').should be_nil
    Game.first(:version => 'UNH').should_not be_nil
  end

  it "should not change the version info from variants without development" do
    Game.new(:version => '3.4.3',
             :user_id => 1,
             :server_id => 1,
             :death => 'ascended').save!

    Game.first(:version => '3.4.3').should_not be_nil
  end
end

describe Game, ".defeated_medusa?" do
  it "returns true if Medusa was killed" do
    # standard xlogfile method
    g = Game.new(:version => '3.4.3', :death => '', :achieve => "0x800")
    g.defeated_medusa?.should be_true

    g = Game.new(:version => '3.4.3', :death => '', :achieve => "0x1802")
    g.defeated_medusa?.should be_true

    # event method
    g = Game.new(:version => '3.4.3', :death => '', :event => "4096")
    g.defeated_medusa?.should be_true

    g = Game.new(:version => '3.4.3', :death => '', :event => "65535")
    g.defeated_medusa?.should be_true
  end

  it "returns false if Medusa was not killed" do
    # standard xlogfile method
    g = Game.new(:version => '3.4.3', :death => '', :achieve => "0x0")
    g.defeated_medusa?.should be_false

    # event method
    g = Game.new(:version => '3.4.3', :death => '', :event => "0")
    g.defeated_medusa?.should be_false
  end
end

describe Game, ".ascended_heaven_or_hell?" do
  it "returns correct result if ascended in Heaven or Hell" do
    g = Game.new(:version => '3.4.3', :death => 'ascended', :mode => "debug")
    g.ascended_heaven_or_hell?.should be_false

    g = Game.new(:version => '3.4.3', :death => 'killed', :mode => "hoh")
    g.ascended_heaven_or_hell?.should be_false

    g = Game.new(:version => '3.4.3', :death => 'ascended', :mode => "hoh")
    g.ascended_heaven_or_hell?.should be_true

    g = Game.new(:version => '3.4.3', :death => 'defied the gods', :mode => "hoh")
    g.ascended_heaven_or_hell?.should be_true
  end
end
