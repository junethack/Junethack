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
end
