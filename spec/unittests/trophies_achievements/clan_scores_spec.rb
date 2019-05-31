require 'spec_helper'

describe Game,"update_clan_scores" do

  before :each do
    clean_database

    clan = Clan.create(name: "clan", admin: [1,1])
    $user = User.create(login: "test_user", clan: clan)
    @server = Server.create(name: 'server_variant')
  end

  # Games are saved first without user_id, the scoring calculation only triggers
  # on updates
  def update_games
    Game.all.each {|g|
      g.user_id = $user.id
      g.save
    }
  end

  it "includes NetHack 1.3d games" do

    Game.create(server_id: @server.id, version: 'NH-1.3d', maxlvl: 10, event: 0x0100, points: 900, endtime: 1000, death: 'escaped (with amulet)', turns: 1023)
    update_games

    expect(ClanScoreEntry.count).to eq 7

    ClanScoreEntry.first(trophy: "most_ascended_combinations").value.should == 1
    ClanScoreEntry.first(trophy: "most_ascensions_in_a_24_hour_period").value.should == 1
    ClanScoreEntry.first(trophy: "most_full_conducts_broken").value.should == 0
    ClanScoreEntry.first(trophy: "most_medusa_kills").value.should == 0
    ClanScoreEntry.first(trophy: "most_unique_deaths").value.should == 1
    ClanScoreEntry.first(trophy: "most_variant_trophy_combinations").value.should == 1
  end

  it "should correctly calculate clan scores" do

    Game.create(server_id: @server.id, version: 'NH-1.3d', maxlvl: 10, points: 900, endtime: 1000, death: 'escaped (with amulet)', turns: 1023)
    Game.create(server_id: @server.id, version: 'v1', achieve: "0x800", points: 9000, endtime: 1000, death: 'ascended', turns: 1023)
    Game.create(server_id: @server.id, version: 'v1', achieve: "0x800", :conduct => 4096, points: 9000, endtime: 1000, death: 'ascended', turns: 1023)
    update_games

    expect(ClanScoreEntry.count).to eq 7 # including clan_winner

    ClanScoreEntry.first(trophy: "most_ascended_combinations").value.should == 2
    ClanScoreEntry.first(trophy: "most_ascensions_in_a_24_hour_period").value.should == 3
    ClanScoreEntry.first(trophy: "most_full_conducts_broken").value.should == 2
    ClanScoreEntry.first(trophy: "most_medusa_kills").value.should == 2
    ClanScoreEntry.first(trophy: "most_unique_deaths").value.should == 2
    ClanScoreEntry.first(trophy: "most_variant_trophy_combinations").value.should == 9
  end

  it "creates clan score history entries" do
    Game.create(server_id: @server.id, version: 'v1', achieve: "0x800", points: 9000, endtime: 1000, death: 'ascended', turns: 1023)
    update_games
    ClanScoreEntry.first(trophy: :most_medusa_kills).value.should == 1
    ClanScoreHistory.all(trophy: :most_medusa_kills).count.should == 1
  end

  it "creates clan score history entries if the value of the trophy changes" do
    attributes = { server_id: @server.id, version: 'v1', achieve: "0x800", points: 9000, endtime: 1000, death: 'ascended', turns: 1023 }
    Game.create(attributes)
    update_games
    ClanScoreEntry.first(trophy: :most_medusa_kills).value.should == 1
    ClanScoreHistory.all(trophy: :most_medusa_kills).count.should == 1

    Game.create(attributes)
    update_games

    ClanScoreEntry.first(trophy: :most_medusa_kills).value.should == 2
    ClanScoreHistory.all(trophy: :most_medusa_kills).count.should == 2
    ClanScoreHistory.all(trophy: :most_medusa_kills).map(&:value).sort == [1, 2]
  end

  describe 'lowest turns getting killed by monsters' do
    let(:attributes) { { server_id: @server.id, version: 'v1', achieve: "0", endtime: 1000 } }
    before :each do
      Game.create(attributes.merge(turns:   1, death: 'killed by a newt'))
      Game.create(attributes.merge(turns:   2, death: 'killed by a dwarf'))
      Game.create(attributes.merge(turns:   4, death: 'killed by a soldier ant'))
      Game.create(attributes.merge(turns:   8, death: 'killed by Asmodeus'))
      Game.create(attributes.merge(turns:  16, death: 'killed by Croesus'))
      Game.create(attributes.merge(turns:  32, death: 'killed by Izchak, the shopkeeper'))
      Game.create(attributes.merge(turns:  64, death: 'killed by Medusa'))
      Game.create(attributes.merge(turns: 128, death: 'killed by the Oracle'))
      update_games
    end

    it 'creates the clan trophy' do
      pending
      expect(ClanScoreEntry.first(trophy: :lowest_turns_for_monster_kills)).not_to be

      Game.create(attributes.merge(turns: 256, death: 'killed by Vlad the Impaler'))
      update_games

      expect(ClanScoreEntry.first(trophy: :lowest_turns_for_monster_kills)).to be
      expect(ClanScoreEntry.first(trophy: :lowest_turns_for_monster_kills).value).to eq 511
    end
  end
end
