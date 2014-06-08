require 'spec_helper'

describe Game,"update_clan_scores" do

  before :each do
    clean_database

    clan = Clan.create(:name => "clan", :admin => [1,1])
    $user = User.create(:login => "test_user", :clan => clan.name)
  end

  # Games are saved first without user_id, the scoring calculation only triggers
  # on updates
  def update_games
    Game.all.each {|g|
      g.user_id = $user.id
      g.save
    }
  end

  it "should acknowledge NetHack 1.3d games" do

    Game.create(:version => 'NH-1.3d', :server_id => 1, :maxlvl => 10, :event => 0x0100, :points => 900, :endtime => 1000, :death => 'escaped (with amulet)', :turns => 1023)
    update_games

    ClanScoreEntry.count.should == 8

    ClanScoreEntry.first(:trophy => "most_ascended_combinations").value.should == 1
    ClanScoreEntry.first(:trophy => "most_ascensions_in_a_24_hour_period").value.should == 1
    ClanScoreEntry.first(:trophy => "most_full_conducts_broken").value.should == 0
    ClanScoreEntry.first(:trophy => "most_log_points").value.should == 2
    ClanScoreEntry.first(:trophy => "most_medusa_kills").value.should == 0
    ClanScoreEntry.first(:trophy => "most_unique_deaths").value.should == 1
    ClanScoreEntry.first(:trophy => "most_variant_trophy_combinations").value.should == 1
  end

  it "should correctly calculate clan scores" do

    Game.create(:version => 'NH-1.3d', :server_id => 1, :maxlvl => 10, :points => 900, :endtime => 1000, :death => 'escaped (with amulet)', :turns => 1023)
    Game.create(:version => 'v1', :server_id => 1, :achieve => "0x800", :points => 9000, :endtime => 1000, :death => 'ascended', :turns => 1023)
    Game.create(:version => 'v1', :server_id => 1, :achieve => "0x800", :points => 9000, :endtime => 1000, :death => 'ascended', :turns => 1023)
    update_games

    ClanScoreEntry.count.should == 8 # including clan_winner

    ClanScoreEntry.first(:trophy => "most_ascended_combinations").value.should == 2
    ClanScoreEntry.first(:trophy => "most_ascensions_in_a_24_hour_period").value.should == 3
    ClanScoreEntry.first(:trophy => "most_full_conducts_broken").value.should == 2
    ClanScoreEntry.first(:trophy => "most_log_points").value.should == 8
    ClanScoreEntry.first(:trophy => "most_medusa_kills").value.should == 2
    ClanScoreEntry.first(:trophy => "most_unique_deaths").value.should == 2
    ClanScoreEntry.first(:trophy => "most_variant_trophy_combinations").value.should == 9
  end

  it "creates clan score history entries" do
    Game.create(:version => 'v1', :server_id => 1, :achieve => "0x800", :points => 9000, :endtime => 1000, :death => 'ascended', :turns => 1023)
    update_games
    ClanScoreEntry.first(:trophy => :most_medusa_kills).value.should == 1
    ClanScoreHistory.all(:trophy => :most_medusa_kills).count.should == 1
  end
end
