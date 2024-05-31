require 'spec_helper'

require 'trophyscore'
require 'userscore'

describe TrophyScore do

  context "given 2 ascended games from the same user with identical score points" do
    server = Server.create(name: 'server_highscore')
    it "should only return one game for highest score trophy calculation" do
      Game.new(server: server,
               user_id: 1,
               version: '',
               points: 2147483647,
               endtime: 1338765479,
               death: 'ascended').save!
      Game.new(server: server,
               user_id: 1,
               version: '',
               points: 2147483647,
               endtime: 1339032798,
               death: 'ascended').save!

      t = TrophyScore.new
      t.highest_scoring_ascension("highscore").size.should == 1
    end
  end

  it "should calculate streaks for ascended games" do
    server = Server.create(name: 'server_streak1')
    Game.new(server_id: server.id, version: '', user_id: 1, endtime: 1000, death: 'quit').save!
    Game.new(server_id: server.id, version: '', user_id: 1, endtime: 2000, death: 'ascended').save!
    Game.new(server_id: server.id, version: '', user_id: 1, endtime: 3000, death: 'ascended').save!
    Game.new(server_id: server.id, version: '', user_id: 1, endtime: 4000, death: 'ascended').save!
    Game.new(server_id: server.id, version: '', user_id: 1, endtime: 5000, death: 'died').save!

    t = TrophyScore.new
    streaks = t.longest_ascension_streaks("streak1")
    streaks[0]['streaks'].should == 3

    u = UserScore.new(1)
    streaks = u.longest_ascension_streak("streak1")
    streaks.should == 3
  end

  context "given ascended games from the same server with a non ascended game in between from a different server" do
    it "should calculate streaks only with games from the same server" do
      server1 = Server.create(name: 'server1_streak2')
      server2 = Server.create(name: 'server2_streak2')

      Game.new(server_id: server1.id, version: '', user_id: 1, endtime: 1000, death: 'ascended').save!
      Game.new(server_id: server2.id, version: '', user_id: 1, endtime: 2000, death: 'ascended').save!
      Game.new(server_id: server1.id, version: '', user_id: 1, endtime: 3000, death: 'ascended').save!

      t = TrophyScore.new
      streaks = t.longest_ascension_streaks("streak2")
      streaks[0]['streaks'].should == 2

      u = UserScore.new(1)
      streaks = u.longest_ascension_streak("streak2")
      streaks.should == 2
    end
  end

  it "should recognize if a player has followed all conducts in ascended games" do
    server = Server.create(name: 'server_conduct')
    user_id1 = 1
    user_id2 = 2
    user_id3 = 3
    version = 'conduct'
    # followed all conducts
    Game.new(server: server, version: version, user_id: user_id1, conduct: 8190, death: 'ascended').save!
    Game.new(server: server, version: version, user_id: user_id1, conduct:    1, death: 'ascended').save!

    # followed all conducts but not in ascended games
    Game.new(server: server, version: version, user_id: user_id2, conduct:    1, death: 'ascended').save!
    Game.new(server: server, version: version, user_id: user_id2, conduct: 4094, death: 'died').save!

    # conducts saved as hexadecimal numbers should also work
    Game.new(server: server, version: version, user_id: user_id3, conduct: '0xfff', death: 'ascended').save!

    expect(all_conducts? user_id1, version).to be true
    expect(all_conducts? user_id2, version).to be false
    expect(all_conducts? user_id3, version).to be true
  end

  describe '.generic_achievements' do
    let(:killed_uniques) { '' }
    let(:user) { User.create login: 'user' }
    before :each do
      game = Game.new(version: 'UNH-', user_id: user.id, server_id: 1, death: 'quit', killed_uniques: killed_uniques).tap(&:save!)
      generic_achievements(game, game.killed_uniques.split(','))
    end

    describe 'with known and unknown achievements in killed_uniques' do
      let(:killed_uniques) { 'defeated_death,defeated_xxx' }
      it 'creates Scoreentry for known achievements' do
        expect(Scoreentry.first(user_id: user.id).trophy).to eq 'defeated_death'
        expect(Scoreentry.count(user_id: user)).to eq 1
      end
    end
  end

  describe '#update_scores' do
    let(:killed_uniques) { '' }
    let(:user) { User.create login: 'user' }
    before :each do
      game = Game.new(version: 'UNH-', user_id: user.id, server_id: 1, death: 'quit', killed_uniques: killed_uniques).tap(&:save!)
      update_scores(game)
    end

    describe '#defeated_all_riders?' do
      let(:killed_uniques) { 'death,famine,pestilence' }
      it 'creates a Scoreentry for defeated_all_riders' do
        expect(Scoreentry.first(trophy: :defeated_all_riders, user_id: user.id)).to be
      end
    end

    describe '#defeated_all_demon_lords_princes?' do
      let(:killed_uniques) { 'asmodeus,baalzebub,demogorgon,dispater,geryon,juiblex,orcus,yeenoghu' }
      it 'creates a Scoreentry for defeated_all_demon_lords_princes' do
        expect(Scoreentry.first(trophy: :defeated_all_demon_lords_princes, user_id: user.id)).to be
      end
    end

    describe '#defeated_all_quest_leaders?' do
      let(:killed_uniques) { 'lord_carnarvon,pelias,shaman_karnov,robert_the_lifer,hippocrates,king_arthur,grand_master,arch_priest,orion,master_of_thieves,lord_sato,twoflower,norn,neferet_the_green' }
      it 'creates a Scoreentry for defeated_all_quest_leaders' do
        expect(Scoreentry.first(trophy: :defeated_all_quest_leaders, user_id: user.id)).to be
      end
    end

    describe '#defeated_all_quest_nemeses?' do
      let(:killed_uniques) { 'schliemann,thoth_amon,tiamat,warden_arianna,cyclops,ixoth,master_kaen,nalzok,scorpius,master_assassin,ashikaga_takauji,lord_surtur,dark_one' }
      it 'creates a Scoreentry for defeated_all_quest_nemeses' do
        expect(Scoreentry.first(trophy: :defeated_all_quest_nemeses, user_id: user.id)).to be
      end
    end
  end

end
