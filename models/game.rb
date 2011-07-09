require 'dm-migrations'
require 'dm-migrations/migration_runner'
require 'trophy_calculations'

$conducts = [
    [0x001, "Foodless", "Foo"],
    [0x002, "Vegan", "Vgn"],    
    [0x004, "Vegetarian", "Vgt"],
    [0x008, "Atheist", "Ath"],
    [0x010, "Weaponless", "Wea"],
    [0x020, "Pacifist", "Pac"],
    [0x040, "Illiterate", "Ill"],
    [0x080, "Polypileless", "Ppl"],
    [0x100, "Polyselfless", "Psf"],
    [0x200, "Wishless", "Wsh"],
    [0x400, "Artiwishless", "Art"],
    [0x800, "Genocideless", "Gen"]
]
$achievements = [
    [:obtained_bell_of_opening,
     "obtained the Bell of Opening"],
    [:entered_gehennom,
     "entered Gehennom"],
    [:obtained_the_candelabrum_of_invocation,
     "obtained the Candelabrum of Invocation"],
    [:obtained_the_book_of_the_dead,
     "obtained the Book of the Dead"],
    [:performed_the_invocation_ritual,
     "performed the Invocation Ritual"],
    [:obtained_the_amulet_of_yendor,
     "obtained the Amulet of Yendor"],
    [:entered_elemental_planes,
     "entered Elemental Planes"],
    [:entered_astral_plane,
     "entered Astral Plane"],
    [:ascended, "ascended"],
    [:obtained_the_luckstone_from_the_mines,
     "obtained the luckstone from the Mines"],
    [:obtained_the_sokoban_prize,
     "obtained the Sokoban Prize"],
    [:defeated_medusa,
     "defeated Medusa"],
]

class Game
    include DataMapper::Resource
    belongs_to :server
    belongs_to :user,   :required => false

    property :id,        Serial
    property :name,      String
    property :deaths,    Integer
    property :deathlev,  Integer
    property :realtime,  Integer
    property :turns,     Integer
    property :birthdate, String
    property :conduct,   String
    property :nconducts, Integer
    property :role,      String
    property :deathdnum, Integer
    property :gender,    String
    property :gender0,   String
    property :uid,       Integer
    property :maxhp,     Integer
    property :points,    Integer
    property :deathdate, String
    property :version,   String
    property :align,     String
    property :align0,    String
    property :starttime, Integer
    property :endtime,   Integer
    property :achieve,   String
    property :nachieves, Integer
    property :hp,        Integer
    property :maxlvl,    Integer
    property :death,     String
    property :race,      String
    property :flags,     String
    property :ascended,  Boolean,
     :default => lambda { |r, p| r.death.start_with? "ascended" or r.death == "escaped (with amulet)" }

    #acehack/unnethack-specific properties
    property :carried,  String
    property :event,    String
    def get_conducts
        $conducts.map{|c| self.conduct & c[0] == c[0] ? c[2] : ""}.join
    end

    #acehack/unnethack-specific properties
    property :deathdname, String
    property :dlev_name,  String
    property :elbereths,  Integer, :default => -1

    ## AcheHand and UnNetHack specific
    # Assault on Fort Knox
    def defeated_croesus?
        event and event.to_i & 0x00800 > 0
    end
    # No membership card
    def defeated_one_eyed_sam?
        event and event.to_i & 0x10000 > 0
    end
    # Too good for quests
    def ascended_without_defeating_nemesis?
        ascended and event and not event.to_i & 0x00400 > 0
    end
    # Too good for Vladbanes
    def ascended_without_defeating_vlad?
        ascended and event and not event.to_i & 0x02000 > 0
    end
    # Too good for... wait, what? How?
    def ascended_without_defeating_rodney?
        ascended and event and not event.to_i & 0x04000 > 0
    end
    # Too good for a brain
    def ascended_without_defeating_cthulhu?
        ascended and event and not event.to_i & 0x20000 > 0
    end
    # Hoarder (ascended carrying all the invocation items)
    def ascended_with_all_invocation_items?
        ascended and carried and carried.to_i & 14 > 0
    end

    ## NetHack 1.3d specific
    # got crowned
    def got_crowned?
        event and event.to_i & 0x00200 > 0
    end
    # entered Hell
    def entered_hell?
        event and event.to_i & 0x00020 > 0
    end
    # defeated Rodney
    def defeated_rodney?
        event and event.to_i & 0x00040 > 0
    end

    after :update do
        update_scores(self)
    end
end


DataMapper::MigrationRunner.migration( 1, :create_indexes ) do
  up do
    execute 'CREATE INDEX "index_games_endtime_user_id" ON "games" ("endtime" desc, "user_id");'
    execute 'CREATE INDEX "index_games_highscore" ON "games" ("user_id", "death", "server_id", "points","endtime");'
    execute 'CREATE INDEX "index_games_user_id_version" ON "games" ("user_id", "version");'
  end
  down do
    execute 'DROP INDEX "index_games_endtime_user_id"';
    execute 'DROP INDEX "index_games_highscore"';
    execute 'DROP INDEX "index_games_user_id_version"';
  end
end

DataMapper::MigrationRunner.migration( 2, :create_trophy_indexes ) do
  up do
    execute 'CREATE INDEX "index_trophy_ascensions" ON "games" ("ascended" desc, "user_id", "version");'
  end
  down do
    execute 'DROP INDEX "index_trophy_ascensions"';
  end
end

