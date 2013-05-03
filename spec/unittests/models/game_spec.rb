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
