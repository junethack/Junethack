require 'spec_helper'

describe Individualtrophy do

  before :each do
    User.create(:login => "test_user")
    Event.destroy
    Individualtrophy.destroy
  end

  it "should add user unique cross variant achievements" do
    Individualtrophy.count.should == 0

    # add achievement
    Individualtrophy.add(1, nil, :test_achievement, "test_achievement.png")
    Individualtrophy.count.should == 1

    # only one achievement per user
    Individualtrophy.add(1, nil, :test_achievement, "test_achievement.png")
    Individualtrophy.count.should == 1
  end

  it "should add Events for cross variant achievements" do
    Event.count.should == 0

    # add achievement
    Individualtrophy.add(1, "test_achievement", :test_achievement, "test_achievement.png")
    Event.count.should == 1

    # only one achievement per user
    Individualtrophy.add(1, "test_achievement", :test_achievement, "test_achievement.png")
    Event.count.should == 1

    Event.first.text.should == 'Achievement "test_achievement" unlocked by test_user!'
  end
end

describe Game,"saving of cross variant achievements" do
 
  before :each do
    User.create(:login => "test_user")
    Event.destroy
    Game.destroy
    Individualtrophy.destroy
  end

  # Games are saved first without user_id, the scoring calculation only triggers
  # on updates
  def update_games
    Game.all.each {|g|
      g.user_id = 1
      g.save
    }
  end

  it "should correctly create cross variant achievements" do

    Individualtrophy.count.should == 0
    Event.count.should == 0

    Game.create(:version => 'v1', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended')
    Game.create(:version => 'v2', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended')
    Game.create(:version => 'v3', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended')
    Game.create(:version => 'v4', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended')
    Game.create(:version => 'v5', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended')
    update_games
    Individualtrophy.count.should == 0
    Event.count.should == 0

    Game.create(:version => 'v6', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended')
    update_games
    Individualtrophy.count.should == 3
    Event.count.should == 3
  end
end
