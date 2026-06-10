require 'spec_helper'

require 'trophy_calculations'

describe "EvilHack trophies" do

  before :each do
    clean_database
    Trophy.seed_trophies

    $user = User.create(login: 'evil_player')
    $server = Server.create(name: 'test_evh', url: 'http://example.ignore/')
  end

  # Games are saved first without user_id, the scoring calculation only
  # triggers on updates.
  def create_game(params = {})
    game = Game.create({server: $server, version: '', death: 'died', endtime: 1000}.merge(params))
    game.user_id = $user.id
    game.save!
    game
  end

  def scoreentry(trophy)
    Scoreentry.find_by(user_id: $user.id, variant: 'evh', trophy: trophy)
  end

  describe 'conduct trophies from the conductX xlogfile field' do
    it 'awards never_abused_alignment for an ascension that kept the conduct' do
      create_game(death: 'ascended', conductX: 'wishless,never_abused_alignment')
      expect(scoreentry(:never_abused_alignment)).to be
    end

    it 'does not award never_abused_alignment when the conduct was broken' do
      create_game(death: 'ascended', conductX: 'wishless,never_died')
      expect(scoreentry(:never_abused_alignment)).to be_nil
    end

    it 'does not award conduct trophies for non-ascended games' do
      create_game(death: 'killed by a newt',
                  conductX: 'never_abused_alignment,never_forged_an_artifact')
      expect(scoreentry(:never_abused_alignment)).to be_nil
      expect(scoreentry(:never_forged_an_artifact)).to be_nil
    end

    it 'awards the new EvilHack conduct trophies' do
      create_game(death: 'ascended',
                  conductX: 'blindfolded,nudist,never_died,never_forged_an_artifact,' \
                            'never_acquired_magic_resistance,never_acquired_reflection')
      [:ascended_permablind, :ascended_nudist, :never_died,
       :never_forged_an_artifact, :never_acquired_magic_resistance,
       :never_acquired_reflection].each { |trophy|
        expect(scoreentry(trophy)).to be
      }
    end

    it 'still awards the conduct trophies shared with xNetHack' do
      create_game(death: 'ascended',
                  conductX: 'never_had_a_pet,never_touched_an_artifact,hallucinating,deaf')
      [:ascended_petless, :ascended_artifactless,
       :ascended_permahallu, :ascended_permadeaf].each { |trophy|
        expect(scoreentry(trophy)).to be
      }
    end
  end

  describe Game, '#ascended_without_elbereth?' do
    it 'is false for an EvilHack ascension that only kept the petless conduct' do
      # 0x1000 is "never had a pet" in EvilHack, not elberethless
      g = Game.new(server: $server, version: '', death: 'ascended',
                   conduct: '0x1000', conductX: 'never_had_a_pet')
      expect(g.ascended_without_elbereth?).to be false
    end

    it 'is true for an EvilHack ascension that kept the elberethless conduct' do
      g = Game.new(server: $server, version: '', death: 'ascended',
                   conduct: '0x4000', conductX: 'never_had_a_pet,elberethless')
      expect(g.ascended_without_elbereth?).to be true
    end

    it 'keeps the conduct bit check for other variants' do
      g = Game.new(version: 'UNH-5.3.2', death: 'ascended', conduct: '0x1000')
      expect(g.ascended_without_elbereth?).to be true
    end
  end

  describe 'unique monster trophies via killed_uniques' do
    it 'awards trophies for the new EvilHack uniques' do
      create_game(killed_uniques: "Tal'Gath,Baba Yaga,Master Po,Archbishop of Moloch,Charon")
      [:defeated_talgath, :defeated_baba_yaga, :defeated_master_po,
       :defeated_archbishop_of_moloch, :defeated_charon].each { |trophy|
        expect(scoreentry(trophy)).to be
      }
    end
  end

  describe 'location and progress achievements via achieveX' do
    it 'awards the new location and progress trophies' do
      create_game(achieveX: 'entered_gehennom,entered_wiztower,entered_hidden_dungeon,' \
                            'got_crowned,entered_quest_portal_level,quest_completed')
      [:entered_wiztower, :entered_hidden_dungeon, :got_crowned,
       :entered_quest_portal_level, :quest_completed].each { |trophy|
        expect(scoreentry(trophy)).to be
      }
    end
  end

  describe 'quest aggregate trophies' do
    evilhack_leaders = [
      :defeated_lord_carnarvon, :defeated_pelias, :defeated_shaman_karnov,
      :defeated_hippocrates, :defeated_king_arthur, :defeated_master_po,
      :defeated_arch_priest, :defeated_orion, :defeated_master_of_thieves,
      :defeated_lord_sato, :defeated_twoflower, :defeated_norn,
      :defeated_neferet_the_green, :defeated_robert_the_lifer,
      :defeated_archbishop_of_moloch, :defeated_elanee,
    ]

    evilhack_nemeses = [
      :defeated_thoth_amon, :defeated_annam, :defeated_cyclops,
      :defeated_ixoth, :defeated_master_kaen, :defeated_nalzok,
      :defeated_scorpius, :defeated_master_assassin,
      :defeated_ashikaga_takauji, :defeated_lord_surtur, :defeated_dark_one,
      :defeated_minion_of_huhetotl, :defeated_warden_arianna,
      :defeated_paladin, :defeated_baba_yaga,
    ]

    def award(trophies)
      trophies.each { |trophy|
        Scoreentry.find_or_create_by(user_id: $user.id, variant: 'evh', trophy: trophy)
      }
    end

    it 'recognizes the EvilHack quest leader roster' do
      game = Game.new(server: $server, version: '', user_id: $user.id)
      award(evilhack_leaders)
      expect(defeated_all_quest_leaders?(game)).to be true
    end

    it 'requires Master Po instead of the Grand Master for EvilHack' do
      game = Game.new(server: $server, version: '', user_id: $user.id)
      award(evilhack_leaders - [:defeated_master_po] + [:defeated_grand_master])
      expect(defeated_all_quest_leaders?(game)).to be false
    end

    it 'recognizes the EvilHack quest nemesis roster' do
      game = Game.new(server: $server, version: '', user_id: $user.id)
      award(evilhack_nemeses)
      expect(defeated_all_quest_nemeses?(game)).to be true
    end

    it 'requires Annam instead of Tiamat for EvilHack' do
      game = Game.new(server: $server, version: '', user_id: $user.id)
      award(evilhack_nemeses - [:defeated_annam] + [:defeated_tiamat])
      expect(defeated_all_quest_nemeses?(game)).to be false
    end
  end
end
