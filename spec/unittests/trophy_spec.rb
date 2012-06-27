require 'rubygems'
require 'bundler/setup'

require 'trophyscore'
require 'database'

describe TrophyScore do
  context "given 2 ascended games from the same user with identical score points" do
    it "should only return one game for highest score trophy calculation" do
      Game.new(:version => 'highscore',
               :user_id => 1,
               :server_id => 1,
               :points => 2147483647,
               :endtime => 1338765479,
               :death => 'ascended').save!
      Game.new(:version => 'highscore',
               :user_id => 1,
               :server_id => 1,
               :points => 2147483647,
               :endtime => 1339032798,
               :death => 'ascended').save!

      t = TrophyScore.new
      t.highest_scoring_ascension("highscore").size.should == 1
    end
  end

  it "should calculate streaks for ascended games" do

    Game.new(:version => 'streak1', :user_id => 1, :server_id => 1, :endtime => 1000, :death => 'quit').save!
    Game.new(:version => 'streak1', :user_id => 1, :server_id => 1, :endtime => 2000, :death => 'ascended').save!
    Game.new(:version => 'streak1', :user_id => 1, :server_id => 1, :endtime => 3000, :death => 'ascended').save!
    Game.new(:version => 'streak1', :user_id => 1, :server_id => 1, :endtime => 4000, :death => 'ascended').save!
    Game.new(:version => 'streak1', :user_id => 1, :server_id => 1, :endtime => 5000, :death => 'died').save!

    t = TrophyScore.new
    streaks = t.longest_ascension_streaks("streak1")
    streaks[0]['streaks'].should == 3
  end

  context "given ascended games from the same server with a non ascended game in between from a different server" do
    it "should calculate streaks only with games from the same server" do

      Game.new(:version => 'streak2', :user_id => 1, :server_id => 1, :endtime => 1000, :death => 'ascended').save!
      Game.new(:version => 'streak2', :user_id => 1, :server_id => 2, :endtime => 2000, :death => 'ascended').save!
      Game.new(:version => 'streak2', :user_id => 1, :server_id => 1, :endtime => 3000, :death => 'ascended').save!

      t = TrophyScore.new
      streaks = t.longest_ascension_streaks("streak2")
      streaks[0]['streaks'].should == 2
    end
  end

  it "should recognize if a player has followed all conducts in ascended games" do

    user_id1 = 1
    user_id2 = 2
    user_id3 = 3
    version = 'conduct'
    # followed all conducts
    Game.new(:version => version, :user_id => user_id1, :server_id => 1, :conduct => 4094, :death => 'ascended').save!
    Game.new(:version => version, :user_id => user_id1, :server_id => 1, :conduct =>    1, :death => 'ascended').save!

    # followed all conducts but not in ascended games
    Game.new(:version => version, :user_id => user_id2, :server_id => 1, :conduct =>    1, :death => 'ascended').save!
    Game.new(:version => version, :user_id => user_id2, :server_id => 1, :conduct => 4094, :death => 'died').save!

    # conducts saved as hexadecimal numbers should also work
    Game.new(:version => version, :user_id => user_id3, :server_id => 1, :conduct => '0xfff', :death => 'ascended').save!

    (all_conducts? user_id1, version).should be_true
    (all_conducts? user_id2, version).should be_false
    (all_conducts? user_id3, version).should be_true
  end
end
