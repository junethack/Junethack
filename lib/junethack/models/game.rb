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
     "obtained the Bell of Opening",
     "m-bell.png"],
    [:entered_gehennom,
     "entered Gehennom",
     "m-gehennom.png"],
    [:obtained_the_candelabrum_of_invocation,
     "obtained the Candelabrum of Invocation",
     "m-candelabrum.png"],
    [:obtained_the_book_of_the_dead,
     "obtained the Book of the Dead",
     "m-book.png"],
    [:performed_the_invocation_ritual,
     "performed the Invocation Ritual",
     "m-invocation.png"],
    [:obtained_the_amulet_of_yendor,
     "obtained the Amulet of Yendor",
     "m-amulet.png"],
    [:entered_elemental_planes,
     "entered Elemental Planes",
     "m-planes.png"],
    [:entered_astral_plane,
     "entered Astral Plane",
     "m-astral.png"],
    [:ascended, 
     "ascended", 
     "ascension.png"],
    [:obtained_the_luckstone_from_the_mines,
     "obtained the luckstone from the Mines",
     "m-luckstone.png"],
    [:obtained_the_sokoban_prize,
     "obtained the Sokoban Prize",
     "m-soko.png"],
    [:defeated_medusa,
     "defeated Medusa",
     "m-medusa.png"],
]

$trophy_names = {
    "ascended" => "ascended",

    "ascended_old" => "ascended",
    "crowned" => "got crowned",
    "entered_hell" => "entered Hell",
    "defeated_old_rodney" => "defeated Rodney",

    "obtained_bell_of_opening" => "obtained the Bell of Opening",
    "entered_gehennom" => "entered Gehennom",
    "obtained_the_candelabrum_of_invocation" => "obtained the Candelabrum of Invocation",
    "obtained_the_book_of_the_dead" => "obtained the Book of the Dead",
    "performed_the_invocation_ritual" => "performed the Invocation Ritual",
    "obtained_the_amulet_of_yendor" => "obtained the Amulet of Yendor",
    "entered_elemental_planes" => "entered Elemental Planes",
    "entered_astral_plane" => "entered Astral Plane",
    "ascended" => "ascended",
    "obtained_the_luckstone_from_the_mines" => "obtained the luckstone from the Mines",
    "obtained_the_sokoban_prize" => "obtained the Sokoban Prize",
    "defeated_medusa" => "defeated Medusa",

    "bought_oracle_consultation" => "bought an Oracle consultation",
    "accepted_for_quest" => "reached the Quest portal level",
    "defeated_quest_nemesis" => "defeated the Quest Nemesis",
    "defeated_medusa" => "defeated Medusa",
    "event_entered_gehennom_front_way" => "entered Gehennom the front way",
    "defeated_vlad" => "defeated Vlad",
    "defeated_rodney" => "defeated Rodney at least once",
    "did_invocation" => "did the Invocation Ritual",
    "defeated_a_high_priest" => "defeated a High Priest",
    "entered_planes" => "entered the Elemental Planes",
    "entered_astral" => "entered the Astral Plane",
    "escapologist" => "escaped in celestial disgrace",

    "ascended_without_defeating_nemesis" => "Too good for quests (ascended without defeating the quest nemesis)",
    "ascended_without_defeating_vlad" => "Too good for Vladbanes (ascended without defeating Vlad)",
    "ascended_without_defeating_rodney" => "Too good for... wait, what? How? (ascended without defeating Rodney)",
    "ascended_without_defeating_cthulhu" => "Too good for a brain (ascended without defeating Cthulhu)",
    "ascended_with_all_invocation_items" => "Hoarder (ascended carrying all the invocation items)",
    "defeated_croesus" => "Assault on Fort Knox (defeated Croesus)",
    "defeated_one_eyed_sam" => "No membership card (defeated One-Eyed Sam)",

    # Cross-Variant
    "walk_in_the_park"    => "Walk in the Park: finish a game in half of the variants",
    "sightseeing_tour"    => "Sightseeing Tour: finish a game in all variants",
    "backpacking_tourist" => "Backpacking Tourist: get a trophy for half of the variants",
    "globetrotter"        => "Globetrotter: get a trophy for each variant",
    "hemi_stoner"         => "Hemi-Stoner: defeat Medusa in half of the variants",
    "anti_stoner"         => "Anti-Stoner: defeat Medusa in all variants",
    "prince_of_the_world" => "Prince of the World: ascend in half of the variants",
    "king_of_the_world"   => "King of the World: ascend in all variants",

    # Clan
    "most_ascensions_in_a_24_hour_period" => "Most ascensions in a 24 hour period",
    "most_ascended_combinations" => "Most ascended variant/role/race/alignment/gender combinations (starting)",
    "most_points" => "Most points",
    "most_unique_deaths" => "Most unique deaths",
    "most_variant_trophy_combinations" => "Most variant/trophy combinations",
}

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
    property :conduct,   String, :default => 0
    property :nconducts, Integer,
     :default => lambda { |r, p| (Integer r.conduct).to_s(2).count("1") } # count the number of bits set in conduct
    property :role,      String
    property :deathdnum, Integer
    property :gender,    String
    property :gender0,   String
    property :uid,       Integer
    property :maxhp,     Integer
    property :points,    Integer
    property :deathdate, String
    property :version,   String
    def version=(new_version)
      new_version = "UNH" if new_version.start_with? 'UNH-'
      super new_version
    end

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
     :default => lambda { |r, p| r.death.start_with? "ascended" or r.death == "escaped (with amulet)" or r.death.start_with? "defied" }

    before :valid?, :trim_death
    # we need to limit the size of deaths
    def trim_death(context = :default)
       self.death = death[0,255]
    end

    # acehack/unnethack-specific properties
    property :carried,  String
    property :event,    String
    def get_conducts
        $conducts.map{|c| self.conduct & c[0] == c[0] ? c[2] : ""}.join
    end

    # acehack/unnethack-specific properties
    property :deathdname, String
    property :dlev_name,  String
    property :elbereths,  Integer, :default => -1

    property :xplevel, Integer, :default => 0
    property :exp,     Integer, :default => 0
    property :mode,    String
    property :gold,    Integer, :default => -1

    # nethack4-specific properties
    property :charname, String
    property :extrinsic, String
    property :intrinsic, String
    property :temporary, String
    property :starttimeus, Integer
    property :endtimeus,   Integer

    def defeated_medusa?
        (achieve and achieve.hex & 0x00800 > 0) or (event_defeated_medusa?)
    end

    ## AceHack and UnNetHack specific
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
        version.start_with? "UNH" and ascended and event and not event.to_i & 0x20000 > 0
    end
    # Hoarder (ascended carrying all the invocation items)
    def ascended_with_all_invocation_items?
        ascended and carried and carried.to_i & 14 > 0
    end
    # Heaven or Hell
    def ascended_heaven_or_hell?
        ascended and mode and mode == "hoh"
    end

    ## NetHack 1.3d specific
    # ascension / escaped (with the amulet)
    def event_ascended?
        event and event.to_i & 0x00100 > 0
    end
    # got crowned
    def got_crowned?
        event and event.to_i & 0x00200 > 0
    end
    # entered Hell
    def entered_hell?
        return false if version != 'NH-1.3d'
        (event and event.to_i & 0x00020 > 0) or maxlvl >= 30
    end
    # defeated Rodney
    def defeated_rodney?
        event and event.to_i & 0x00040 > 0
    end

    # UnNetHack and AceHack specific
    def event_bought_oracle_consultation?
        event and event.to_i & 0x00001 > 0
    end
    def event_accepted_for_quest?
        event and event.to_i & 0x00004 > 0
    end
    def event_defeated_quest_nemesis?
        event and event.to_i & 0x00400 > 0
    end
    def event_defeated_medusa?
        event and event.to_i & 0x01000 > 0
    end
    def event_entered_gehennom_front_way?
        event and event.to_i & 0x00020 > 0
    end
    def event_defeated_vlad?
        event and event.to_i & 0x02000 > 0
    end
    def event_defeated_rodney?
        event and event.to_i & 0x04000 > 0
    end
    def event_did_invocation?
        event and event.to_i & 0x00080 > 0
    end
    def event_defeated_a_high_priest?
        event and event.to_i & 0x08000 > 0
    end
    def entered_planes?        
        deathlev < 0 and (not death.start_with?('went to heaven prematurely'))
    end
    def entered_astral?
        deathlev == -5
    end

    def escapologist?
        death == "escaped (in celestial disgrace)"
    end

    def variant_name
        return $variants_mapping[version]
    end

    def Game.max_ascended_endtime
        Game.max :endtime, :ascended => true, :conditions => [ 'user_id is not null' ]
    end

    def Game.max_endtime
        Game.max :endtime, :conditions => [ 'user_id is not null' ]
    end

    def mini_croesus?
        gold >= 100_000
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


class NormalizedDeath
    include DataMapper::Resource
    belongs_to :game,  :key => true
    belongs_to :user,  :required => false

    property :death,     String
end
