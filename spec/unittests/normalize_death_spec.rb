require 'spec_helper'

require 'normalize_death'

describe Game,"normalization of death strings" do
  before(:all) do
    @game = Game.new
  end

  it "should not change simple ascended/quit/escaped" do
    ["ascended", "quit", "escaped"].each do |death|
      @game.death = death
      @game.normalize_death.should == @game.death
    end
  end

  it "should not change NetHack 1.3d deaths" do
    # NetHack 1.3d "ascension" message
    @game.death = "escaped (with amulet)"
    @game.normalize_death.should == @game.death
  end

  it "should remove everything with ', while anything'" do
    @game.death = "killed by a monster, while helpless"
    @game.normalize_death.should == "killed by a monster"
    @game.death = "killed by a monster, while sleeping"
    @game.normalize_death.should == "killed by a monster"
    @game.death = "killed by a monster, while frozen by a monster's gaze"
    @game.normalize_death.should == "killed by a monster"
    @game.death = "killed by a monster, while fainted from lack of food"
    @game.normalize_death.should == "killed by a monster"
    @game.death = "killed by a monster, while frozen by a potion"
    @game.normalize_death.should == "killed by a monster"
    @game.death = "killed by a monster, while praying"
    @game.normalize_death.should == "killed by a monster"
    @game.death = "killed by a monster, while reading a book"
    @game.normalize_death.should == "killed by a monster"
    @game.death = "killed by a gnome, while being frightened to death"
    @game.normalize_death.should == "killed by a gnome"
    @game.death = "killed by a gnome, while disrobing"
    @game.normalize_death.should == "killed by a gnome"
    @game.death = "killed by a gnome, while dragging an iron ball"
    @game.normalize_death.should == "killed by a gnome"
    @game.death = "killed by a gnome, while dressing up"
    @game.normalize_death.should == "killed by a gnome"
    @game.death = "killed by a gnome, while jumping around"
    @game.normalize_death.should == "killed by a gnome"
    @game.death = "killed by a gnome, while paralyzed by a monster"
    @game.normalize_death.should == "killed by a gnome"
    @game.death = "killed by a gnome, while unconscious from rotten food"
    @game.normalize_death.should == "killed by a gnome"
  end

  it "should remove 'hallucinogen-distorted'" do
    @game.death = "killed by a hallucinogen-distorted monster"
    @game.normalize_death.should == "killed by a monster"
  end

  it "should remove 'invisible'" do
    @game.death = "killed by an invisible Green-elf"
    @game.normalize_death.should == "killed by a Green-elf"
    @game.death = "killed by invisible Croesus"
    @game.normalize_death.should == "killed by Croesus"
    @game.death = "killed by the invisible Master of Thieves"
    @game.normalize_death.should == "killed by Master of Thieves"
    @game.death = "petrified by an invisible chickatrice"
    @game.normalize_death.should == "petrified by a chickatrice"
    @game.death = "killed by an invisible hallucinogen-distorted Uruk-hai"
    @game.normalize_death.should == "killed by a Uruk-hai"
  end

  it "should remove 'hallucinogen-distorted'" do
    @game.death = "killed by a hallucinogen-distorted monster"
    @game.normalize_death.should == "killed by a monster"
  end

  it "should make them gender-neutral" do
    @game.death = "teleported out of the dungeon and fell to her death"
    @game.normalize_death.should == "teleported out of the dungeon and fell to eir death"
    @game.death = "teleported out of the dungeon and fell to his death"
    @game.normalize_death.should == "teleported out of the dungeon and fell to eir death"

    @game.death = "killed by her own pick-axe"
    @game.normalize_death.should == "killed by eir own pick-axe"
    @game.death = "killed by his own pick-axe"
    @game.normalize_death.should == "killed by eir own pick-axe"

    @game.death = "caught herself in her own magical blast"
    @game.normalize_death.should == "caught eirself in eir own magical blast"
    @game.death = "caught himself in his own magical blast"
    @game.normalize_death.should == "caught eirself in eir own magical blast"

    @game.death = "killed herself with her bullwhip"
    @game.normalize_death.should == "killed eirself with eir bullwhip"
    @game.death = "killed himself with his bullwhip"
    @game.normalize_death.should == "killed eirself with eir bullwhip"

    @game.death = "shot herself with a death ray"
    @game.normalize_death.should == "shot eirself with a death ray"
    @game.death = "shot himself with a death ray"
    @game.normalize_death.should == "shot eirself with a death ray"

    @game.death = "zapped herself with a spell"
    @game.normalize_death.should == "zapped eirself with a spell"
    @game.death = "zapped himself with a spell"
    @game.normalize_death.should == "zapped eirself with a spell"

    @game.death = "killed by using a magical horn on herself"
    @game.normalize_death.should == "killed by using a magical horn on eirself"
    @game.death = "killed by using a magical horn on himself"
    @game.normalize_death.should == "killed by using a magical horn on eirself"
  end

  it "should remove everything after called or named" do
    @game.death = "killed by a gnome called killer"
    @game.normalize_death.should == "killed by a gnome"

    @game.death = "killed by a war hammer named Mjollnir"
    @game.normalize_death.should == "killed by a war hammer"
  end

  it "doesn't remove (with the Amulet)" do
    @game.death = "killed by a Archon (with the Amulet)"
    expect(@game.normalize_death).to eq "killed by a Archon (with the Amulet)"
  end

  it "should substitute everything after killed by kicking with something" do
    @game.death = "killed by kicking a slime mold"
    @game.normalize_death.should == "killed by kicking something"
  end

  describe "if killed by kicking gold pieces" do
    it "should not change the death if it's just one gold piece" do
      @game.death = "killed by kicking a gold piece"
      @game.normalize_death.should == "killed by kicking a gold piece"
    end
    it "should " do
      @game.death = "killed by kicking 0 gold pieces"
      @game.normalize_death.should == "killed by kicking 0 gold pieces"
    end
    it "should " do
      @game.death = "killed by kicking 1234 gold pieces"
      @game.normalize_death.should == "killed by kicking gold pieces"
    end
    it "should " do
      @game.death = "killed by kicking -1234 gold pieces"
      @game.normalize_death.should == "killed by kicking a negative amount of gold pieces"
    end
  end

  it "should substitute everything after choked on with something" do
    result = "choked on something"
    @game.death = "choked on the blessed Excalibur"
    @game.normalize_death.should == result

    @game.death = "choked on a wraith corpse"
    @game.normalize_death.should == result
  end

  it "should substitute the name of a deity" do
    result = "killed by the wrath of a deity"
    @game.death = "killed by the wrath of Chih Sung-tzu"
    @game.normalize_death.should == result
  end

  it "substitutes the name of ghosts" do
    test = {
      "1 killed by the ghost of Kenneth Arnold" => "1 killed by a ghost",
      "2 killed by the ghost of coffeebug" => "2 killed by a ghost",
      "3 killed by a ghost of Karnov" => "3 killed by a ghost",
      "4 killed by ghost of Karnov" => "4 killed by a ghost",
    }
    test.each {|message, result|
      @game.death = message
      expect(@game.normalize_death).to eq result
    }
  end

  it "should substitute the name of a shopkeeper" do
    test = {
      "killed by Ms. Pakka Pakka, the shopkeeper" => "killed by a shopkeeper",
      "killed by Ms. Pakka Pakka; the shopkeeper" => "killed by a shopkeeper",
      "killed by Ms. Pakka Pakka, the shopkeeper's magic missile" => "killed by a shopkeeper's magic missile",
      "killed by Ms. Sipaliwini, the shopkeeper's wand" => "killed by a shopkeeper's wand"
    }
    test.each {|message, result|
      @game.death = message
      @game.normalize_death.should == result
    }
  end

  it "normalizes information about wounded/uninjured state" do
    test = {
      "killed by a moderately wounded leocrotta" => "killed by a leucrotta",
      "killed by a uninjured goblin" => "killed by a goblin"
    }
    test.each {|message, result|
      @game.death = message
      @game.normalize_death.should == result
    }
  end
  
  it "normalizes death messages on every possible starting mount" do
      @game.death = "slipped while mounting a horse"
      expect(@game.normalize_death).to eq "slipped while mounting eir steed"
  end

  it "normalizes SlashEM'Extended monster and item names" do
    test = {
       "a monster (%s )":                    "a monster",
       "unwisely ate the body of a monster (%s)": "unwisely ate the body of a monster",
       "slipped while mounting a monster (%s)":   "slipped while mounting eir steed",
       "unwisely tried to eat a monster (%s)":    "unwisely tried to eat a monster",

       "kicking a monster corpse (%s) without boots": "kicking a monster corpse without boots",
       "tasting petrifying meat (%s)": "tasting petrifying meat",
       "touching an artifact (%s)":    "touching an artifact",
       "petrifying egg (%s)":          "petrifying egg",
       "the wrath of a deity (%s)":    "the wrath of a deity",
    }
    test.each {|message, result|
      @game.death = message
      expect(@game.normalize_death).to eq result
    }
  end

  describe '#normalize_monster' do
    it "doesn't strip the shopkeeper's name" do
      test = [
        "killed by hallucinogen-distorted Mr. Izchak, the shopkeeper",
        "killed by invisible Izchak, the shopkeeper",
        "killed by invisible Izchak; the shopkeeper",
        "killed by invisible Mr. Izchak, the shopkeeper",
        "killed by invisible Mr. Izchak, the shopkeeper, while helpless",
        "killed by Izchak; the shopkeeper",
        "killed by Mr. Izchak, the shopkeeper",
        "killed by Ms. Izchak, the shopkeeper",
      ]

      test.each {|message, result|
        @game.death = message
        expect(@game.normalize_monster).to eq 'Izchak'
      }
    end

    it 'shows only the monster name' do
      test = {
        'killed by Izchak, the shopkeeper': 'Izchak',
        'killed by Croesus': 'Croesus',
        'killed by Vlad the Impaler': 'Vlad the Impaler',
        'killed by the Oracle': 'Oracle',
        'killed by a dwarf': 'dwarf',
        'a monster (cockatrice)': 'cockatrice',
        'petrified by catching the eye of Medusa': 'Medusa'
      }
      test.each {|message, result|
        @game.death = message
        expect(@game.normalize_monster).to eq result
      }
    end

  end

end
