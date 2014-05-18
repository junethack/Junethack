require 'rubygems'
require 'bundler/setup'

require 'dm-migrations'
require 'dm-migrations/migration_runner'
require 'trophy_calculations'

class Trophy
    include DataMapper::Resource

    property :id,        Serial
    property :variant,   String, :required => false
    property :trophy,    String, :required => true
    property :text,      String, :required => true
    property :icon,      String, :required => true
    property :user_competition, Boolean, :required => true, :default => false

    # returns all cross variant trophies
    def Trophy.cross_variant_trophies
        Trophy.all :conditions => ["variant is null"]
    end

    # returns all variant-specific user trophies
    def Trophy.user_trophies variant
        Trophy.all :variant => variant, :user_competition => false, :conditions => [ "trophy not like 'all_%'" ]
    end

    # returns all variant-specific user competition trophies
    def Trophy.user_competition_trophies variant
        Trophy.all :variant => variant, :user_competition => true
    end

    # returns all variant-specific user trophies
    def Trophy.user_all_stuff_trophies variant
        Trophy.all :variant => variant, :conditions => [ "trophy like 'all_%'" ]
    end
    # returns the count of achieved variant-specific user trophies
    def Trophy.achieved_user_all_stuff_trophies_count variant
        Scoreentry.count :variant => variant, :conditions => [ "trophy like 'all_%'" ]
    end

    # used for href
    def anchor
        self.icon[0 ..-5]
    end
    def light_icon
        anchor+"_light.png"
    end
end

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

# create variant specific trophies
def Trophy.check_trophies_for_variant variant_description

  # get variant designator by description
  variant = helper_get_variant_for variant_description

  # check if there are already trophies for this variant
  if (Trophy.first :variant => variant).nil? then
    # NetHack 1.3d
    if variant == "NH-1.3d" then
      Trophy.create :variant => "NH-1.3d", :trophy => "ascended_old", :text => "ascended", :icon => "old-ascension.png"
      Trophy.create :variant => "NH-1.3d", :trophy => "crowned", :text => "got crowned", :icon => "old-crowned.png"
      Trophy.create :variant => "NH-1.3d", :trophy => "entered_hell", :text => "entered Hell", :icon => "old-hell.png"
      Trophy.create :variant => "NH-1.3d", :trophy => "defeated_old_rodney", :text => "defeated Rodney", :icon => "old-wizard.png"
      return
    end

    # Standard achievements
    # all variants get these
    # get current versions
    acehack = helper_get_variant_for 'acehack'
    nethack4 = helper_get_variant_for 'nethack4'
    unnethack = helper_get_variant_for 'unnethack'
    if [acehack, nethack4].include? variant then
      # these variants don't have standard xlogfile achievement flags
      broken_xlogfile = true
    else
      broken_xlogfile = false
    end

    # standard devnull achievement trophies
    Trophy.create :variant => variant, :trophy => "ascended", :text => "ascended", :icon => "ascension.png"
    Trophy.create :variant => variant, :trophy => "escapologist", :text => "escaped in celestial disgrace", :icon => "escapologist.png"
    Trophy.create :variant => variant, :trophy => "entered_astral_plane", :text => "entered Astral Plane", :icon => "m-astral.png"
    Trophy.create :variant => variant, :trophy => "entered_elemental_planes", :text => "entered Elemental Planes", :icon => "m-planes.png"
    Trophy.create :variant => variant, :trophy => "obtained_the_amulet_of_yendor", :text => "obtained the Amulet of Yendor", :icon => "m-amulet.png" if not broken_xlogfile
    Trophy.create :variant => variant, :trophy => "defeated_a_high_priest", :text => "defeated a High Priest", :icon => "m-amulet.png" if broken_xlogfile
    Trophy.create :variant => variant, :trophy => "performed_the_invocation_ritual", :text => "performed the Invocation Ritual", :icon => "m-invocation.png"
    Trophy.create :variant => variant, :trophy => "obtained_the_book_of_the_dead", :text => "obtained the Book of the Dead", :icon => "m-book.png" if not broken_xlogfile
    Trophy.create :variant => variant, :trophy => "defeated_rodney", :text => "defeated Rodney at least once", :icon => "m-book.png" if broken_xlogfile
    Trophy.create :variant => variant, :trophy => "obtained_the_candelabrum_of_invocation", :text => "obtained the Candelabrum of Invocation", :icon => "m-candelabrum.png" if not broken_xlogfile
    Trophy.create :variant => variant, :trophy => "defeated_vlad", :text => "defeated Vlad", :icon => "m-candelabrum.png" if broken_xlogfile
    Trophy.create :variant => variant, :trophy => "entered_gehennom", :text => "entered Gehennom", :icon => "m-gehennom.png" if not broken_xlogfile
    Trophy.create :variant => variant, :trophy => "event_entered_gehennom_front_way", :text => "entered Gehennom the front way", :icon => "m-gehennom.png" if broken_xlogfile
    Trophy.create :variant => variant, :trophy => "defeated_medusa", :text => "defeated Medusa", :icon => "m-medusa.png"
    Trophy.create :variant => variant, :trophy => "obtained_bell_of_opening", :text => "obtained the Bell of Opening", :icon => "m-bell.png" if not broken_xlogfile
    Trophy.create :variant => variant, :trophy => "defeated_quest_nemesis", :text => "defeated the Quest Nemesis", :icon => "m-bell.png" if broken_xlogfile
    Trophy.create :variant => variant, :trophy => "obtained_the_luckstone_from_the_mines", :text => "obtained the luckstone from the Mines", :icon => "m-luckstone.png" if not broken_xlogfile
    Trophy.create :variant => variant, :trophy => "accepted_for_quest", :text => "get accepted to the Quest", :icon => "m-luckstone.png" if broken_xlogfile
    Trophy.create :variant => variant, :trophy => "obtained_the_sokoban_prize", :text => "obtained the Sokoban Prize", :icon => "m-soko.png" if not broken_xlogfile
    Trophy.create :variant => variant, :trophy => "bought_oracle_consultation", :text => "got an Oracle consultation", :icon => "m-soko.png" if broken_xlogfile

    # AceHack, NetHack4 and UnNetHack specific achievements
    if [acehack, nethack4, unnethack].include? variant then
      Trophy.create :variant => variant, :trophy => "ascended_without_defeating_nemesis", :text => "Too good for quests (ascended without defeating the quest nemesis)", :icon => "m-no-nemesis.png"
      Trophy.create :variant => variant, :trophy => "ascended_without_defeating_vlad", :text => "Too good for Vladbanes (ascended without defeating Vlad)", :icon => "m-no-vlad.png"
      Trophy.create :variant => variant, :trophy => "ascended_without_defeating_rodney", :text => "Too good for... wait, what? How? (ascended without defeating Rodney)", :icon => "m-no-wizard.png"
      Trophy.create :variant => variant, :trophy => "ascended_with_all_invocation_items", :text => "Hoarder (ascended carrying all the invocation items)", :icon => "m-hoarder.png"
      Trophy.create :variant => variant, :trophy => "defeated_croesus", :text => "Assault on Fort Knox (defeated Croesus)", :icon => "m-croesus.png"
      Trophy.create :variant => variant, :trophy => "defeated_one_eyed_sam", :text => "No membership card (defeated One-Eyed Sam)", :icon => "m-sam.png" if variant == unnethack
      Trophy.create :variant => variant, :trophy => "ascended_without_defeating_cthulhu", :text => "Too good for a brain (ascended without defeating Cthulhu)", :icon => "m-no-cthulhu.png" if variant == unnethack
      Trophy.create :variant => variant, :trophy => "mini_croesus", :text => "Mini-Croesus (finish a game with at least 100,000 gold pieces)", :icon => "m-mini-croesus.png" if variant == unnethack
      Trophy.create :variant => variant, :trophy => "heaven_or_hell", :text => "heaven or hell (ascend in 1 HP mode)", :icon => "heaven-or-hell.png" if variant != nethack4
    end

    # user competition trophies
    Trophy.create :variant => variant, :trophy => "most_ascensions", :text => "Most ascensions", :icon => "c-most-ascensions.png", :user_competition => true
    Trophy.create :variant => variant, :trophy => "fastest_ascension_gametime", :text => "Fastest ascension (by turns)", :icon => "c-fastest-gametime.png", :user_competition => true
    Trophy.create :variant => variant, :trophy => "fastest_ascension_realtime", :text => "Fastest ascension (by wall-clock time)", :icon => "c-fastest-realtime.png", :user_competition => true
    Trophy.create :variant => variant, :trophy => "highest_scoring_ascension", :text => "Highest scoring ascension", :icon => "c-highest-score.png", :user_competition => true
    Trophy.create :variant => variant, :trophy => "lowest_scoring_ascension", :text => "Lowest scoring ascension", :icon => "c-lowest-score.png", :user_competition => true
    Trophy.create :variant => variant, :trophy => "most_conducts_ascension", :text => "Most conducts in a single ascension", :icon => "c-most-conducts.png", :user_competition => true
    Trophy.create :variant => variant, :trophy => "longest_ascension_streaks", :text => "Longest ascension streak", :icon => "c-longest-streak.png", :user_competition => true

    # multiple ascension trophies
    Trophy.create :variant => variant, :trophy => "all_conducts", :text => "All conducts: follow each conduct in at least one ascension", :icon => "all-conducts.png"
    Trophy.create :variant => variant, :trophy => "all_roles", :text => "All roles: ascend a character for each role", :icon => "all-roles.png"
    Trophy.create :variant => variant, :trophy => "all_races", :text => "All races: ascend a character of every race", :icon => "all-races.png"
    Trophy.create :variant => variant, :trophy => "all_alignments", :text => "All alignments: ascend a character of every alignment (the starting alignment is considered)", :icon => "all-alignments.png"
    Trophy.create :variant => variant, :trophy => "all_genders", :text => "All genders: ascend a character of each gender (the starting gender is considered)", :icon => "all-genders.png"

  end
end

DataMapper::MigrationRunner.migration( 1, :create_cross_variant_achievements ) do
  up do
    # Cross Variant
    Trophy.create :trophy => "king_of_the_world", :text => "King of the World: ascend in all variants", :icon => "king.png"
    Trophy.create :trophy => "prince_of_the_world", :text => "Prince of the World: ascend in half of the variants", :icon => "prince.png"

    Trophy.create :trophy => "anti_stoner",       :text => "Anti-Stoner: defeated Medusa in all variants", :icon => "anti-stoner.png"
    Trophy.create :trophy => "hemi_stoner",       :text => "Hemi-Stoner: defeat Medusa in half of the variants", :icon => "hemi-stoner.png"

    Trophy.create :trophy => "globetrotter",      :text => "Globetrotter: get a trophy for each variant", :icon => "globetrotter.png"
    Trophy.create :trophy => "backpacking_tourist", :text => "Backpacking Tourist: get a trophy for half of the variants", :icon => "backpacking_tourist.png"

    Trophy.create :trophy => "sightseeing_tour",  :text => "Sightseeing Tour: finish a game in all variants", :icon => "sightseeing.png"
    Trophy.create :trophy => "walk_in_the_park",  :text => "Walk in the Park: finish a game in half of the variants", :icon => "walk_in_the_park.png"
  end

  down do
    Trophy.all.destroy
  end
end

DataMapper::MigrationRunner.migration( 2, :create_clan_trophies ) do

  up do
    # Clan
    Trophy.create :variant => "clan", :trophy => "most_ascensions_in_a_24_hour_period", :text => "Most ascensions in a 24 hour period", :icon => "clan-24h.png"
    Trophy.create :variant => "clan", :trophy => "most_ascended_combinations", :text => "Most ascended variant/role/race/alignment/gender combinations (starting)", :icon => "clan-combinations.png"
    Trophy.create :variant => "clan", :trophy => "most_points", :text => "Most points", :icon => "clan-points.png"
    Trophy.create :variant => "clan", :trophy => "most_unique_deaths", :text => "Most unique deaths", :icon => "clan-deaths.png"
    Trophy.create :variant => "clan", :trophy => "most_variant_trophy_combinations", :text => "Most variant/trophy combinations", :icon => "clan-variant-trophies.png"

    # new clan trophies since 2013
    Trophy.create :variant => "clan", :trophy => "most_medusa_kills", :text => "Most Medusa kills", :icon => "clan-medusa-kills.png"
    Trophy.create :variant => "clan", :trophy => "most_full_conducts_broken", :text => "Most games with all conducts broken", :icon => "clan-full-conducts-broken.png"
    Trophy.create :variant => "clan", :trophy => "most_log_points", :text => "Most logarithmic points", :icon => "clan-points.png"
  end
end

DataMapper::MigrationRunner.migration( 4, :create_variant_trophies ) do
  up do
    # add all already existing variants
    Trophy.check_trophies_for_variant "vanilla"
    Trophy.check_trophies_for_variant "sporkhack"
    Trophy.check_trophies_for_variant "unnethack"
    Trophy.check_trophies_for_variant "acehack"
    Trophy.check_trophies_for_variant "grunthack"
    Trophy.check_trophies_for_variant "nethack4"
  end
end
