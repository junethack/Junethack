require 'spec_helper'

describe Individualtrophy do

  before :each do
    clean_database
    $user = User.create(:login => "test_user")
  end

  it "should add user unique cross variant achievements" do
    Individualtrophy.count.should == 0

    # add achievement
    Individualtrophy.add($user.id, nil, :test_achievement, "test_achievement.png")
    Individualtrophy.count.should == 1

    # only one achievement per user
    Individualtrophy.add($user.id, nil, :test_achievement, "test_achievement.png")
    Individualtrophy.count.should == 1
  end

  it "should add Events for cross variant achievements" do
    Event.count.should == 0

    # add achievement
    Individualtrophy.add($user.id, "test_achievement", :test_achievement, "test_achievement.png")
    Event.count.should == 1

    # only one achievement per user
    Individualtrophy.add($user.id, "test_achievement", :test_achievement, "test_achievement.png")
    Event.count.should == 1

    Event.first.text.should == 'Achievement "test_achievement" unlocked by test_user!'
  end
end

describe Game,"saving of cross variant achievements" do
 
  before :each do
    clean_database
    $user = User.create(:login => "test_user")
  end

  # Games are saved first without user_id, the scoring calculation only triggers
  # on updates
  def update_games
    Game.all.each {|g|
      g.user_id = $user.id
      g.save
    }
  end

  it "should correctly create cross variant achievements" do

    Individualtrophy.count.should == 0
    Event.count.should == 0

    Game.create(:version => 'v1', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended', :turns => 1023)
    Game.create(:version => 'v2', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended', :turns => 1023)
    update_games
    Individualtrophy.count.should == 0
    Event.count.should == 0

    Game.create(:version => 'v3', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended', :turns => 1023)
    update_games # 1/2 cross variant achievements
    Individualtrophy.count.should == 4
    Event.count.should == 4

    Game.create(:version => 'v4', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended', :turns => 1023)
    Game.create(:version => 'v5', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended', :turns => 1023)
    Individualtrophy.count.should == 4
    Event.count.should == 4

    Game.create(:version => 'v6', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended', :turns => 1023)
    Game.create(:version => 'v7', :server_id => 1, :achieve => "0x800", :endtime => 1000, :death => 'ascended', :turns => 1023)
    update_games # full and 1/2 cross variant achievements
    Individualtrophy.count.should == 8
    Event.count.should == 8
  end
end
