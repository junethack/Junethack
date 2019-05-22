require 'rubygems'
require 'bundler/setup'

require 'dm-migrations'
require 'dm-migrations/migration_runner'
require 'trophy_calculations'

class Trophy
    include DataMapper::Resource

    property :id,        Serial
    property :variant,   String, required: false
    property :trophy,    String, required: true
    property :text,      String, required: true
    property :icon,      String, required: true
    property :row,       Integer, default: 1
    property :user_competition, Boolean, required: true, default: false

    # returns all cross variant trophies
    def Trophy.cross_variant_trophies
        Trophy.all :conditions => ["variant is null"]
    end

    # returns all variant-specific user trophies
    def Trophy.user_trophies variant
        Trophy.all variant: variant,
                   user_competition: false,
                   conditions: [ "trophy not like 'all_%'" ],
                   order: [ :row, :id ]
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
    "obtained_the_luckstone_from_the_mines" => "obtained the luckstone from the Mines",
    "obtained_the_sokoban_prize" => "obtained the Sokoban Prize",
    "defeated_medusa" => "defeated Medusa",

    "bought_oracle_consultation" => "bought an Oracle consultation",
    "accepted_for_quest" => "reached the Quest portal level",
    "defeated_quest_nemesis" => "defeated the Quest Nemesis",
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

  raise "#{variant_description} not found" if variant.nil?

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
    nh4k = helper_get_variant_for 'nethack fourk'
    unnethack = helper_get_variant_for 'unnethack'
    dynahack = helper_get_variant_for 'dynahack'
    dnethack = helper_get_variant_for 'dnethack'
    grunthack = helper_get_variant_for 'grunthack'
    fiqhack = helper_get_variant_for 'fiqhack'
    slashthem = helper_get_variant_for 'slashthem'
    slex = helper_get_variant_for "slash'em extended"
    sporkhack = helper_get_variant_for 'sporkhack'
    splicehack = helper_get_variant_for 'splicehack'
    xnethack = helper_get_variant_for 'xnethack'
    nethack36 = helper_get_variant_for '3.6.1'
    evilhack = helper_get_variant_for 'evilhack'
    dnhslex = helper_get_variant_for 'dnethack slex'
    notdnethack = helper_get_variant_for 'notdnethack'

    if [acehack, nethack4, nh4k, dynahack, fiqhack].include? variant then
      # these variants don't have standard xlogfile achievement flags
      broken_xlogfile = true
    else
      broken_xlogfile = false
    end

    # standard devnull achievement trophies
    Trophy.create :variant => variant, :trophy => "ascended", :text => "ascended", :icon => "ascension.png"
    Trophy.create :variant => variant, :trophy => "escapologist", :text => "escaped in celestial disgrace", :icon => "escapologist.png", row: 2
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
    Trophy.create variant: variant, trophy: "bought_oracle_consultation", text: "got an Oracle consultation", icon: "4-oracle-consult.png" if broken_xlogfile

    # AceHack, NetHack4 and UnNetHack specific achievements
    if [acehack, nethack4, unnethack, dynahack, nh4k, fiqhack].include? variant then
      Trophy.create variant: variant, trophy: "ascended_without_defeating_nemesis", text: "Too good for quests (ascended without defeating the quest nemesis)", icon: "m-no-nemesis.png", row: 2
      Trophy.create variant: variant, trophy: "ascended_without_defeating_vlad", text: "Too good for Vladbanes (ascended without defeating Vlad)", icon: "m-no-vlad.png", row: 2
      Trophy.create variant: variant, trophy: "ascended_without_defeating_rodney", text: "Too good for... wait, what? How? (ascended without defeating Rodney)", icon: "m-no-wizard.png", row: 2
      Trophy.create variant: variant, trophy: "ascended_without_elbereth", text: "ascended without writing Elbereth", icon: "m-elbereth.png", row: 2
      Trophy.create variant: variant, trophy: "ascended_with_all_invocation_items", text: "Hoarder (ascended carrying all the invocation items)", icon: "m-hoarder.png", row: 2
      Trophy.create variant: variant, trophy: "defeated_croesus", text: "Assault on Fort Knox (defeated Croesus)", icon: "m-croesus.png", row: 2
    end

    if variant == unnethack
      achievements = [
        [:ascended_without_defeating_cthulhu, "Too good for a brain (ascended without defeating Cthulhu)", "m-no-cthulhu.png", 3],
        [:heaven_or_hell,                     "Heaven or Hell (ascend in 1 HP mode)",                      "heaven-or-hell.png", 3],
        [:mini_croesus,                       "Mini-Croesus (finish a game with at least 25,000 gold pieces)", "m-mini-croesus.png", 3],
        [:better_than_croesus,                "Better than Croesus (finish a game with at least 200,000 gold pieces)", "m-better-than-croesus.png", 3],
        [:bought_oracle_consultation,         'got an Oracle consultation', '4-oracle-consult.png', 3],
      ]
      achievements.each {|achievement|
        icon = achievement[2] || "u-#{achievement[0].to_s.gsub(' ', '_')}.png"
        Trophy.create variant: variant, trophy: achievement[0], text: achievement[1], icon: icon, row: achievement[3]
      }
    end

    if [unnethack, evilhack].include? variant
      achievements = [
        #[:defeated_all_unique_monsters, ", nil, 4], TODO
        [:defeated_all_riders,              'You Are War! (defeated Death, Famine, and Pestilence)', 'defeated_all_riders.png', 4],
        [:defeated_all_quest_leaders,       'You already know the way (defeated all Quest leaders)', 'defeated_all_quest_leaders.png', 4],
        [:defeated_all_quest_nemeses,       "Viel Feind', viel Ehr' (defeated all Quest nemeses)", 'defeated_all_quest_nemeses.png', 4],
        [:defeated_all_demon_lords_princes, 'Demonbuster (defeated all demon lords and princes)', 'defeated_all_demon_lords_princes.png', 4],
        #[:defeated_all_erinyes, ", nil, 4], TODO
        #[:defeated_all_nazgul, ", nil, 4], TODO
        #[:defeated_all_weeping_archangels, ", nil, 4], TODO

        # riders
        [:defeated_death,      'defeated Death', nil, 5],
        [:defeated_famine,     'defeated Famine', nil, 5],
        [:defeated_pestilence, 'defeated Pestilence', nil, 5],
        # uncategorized unique monsters
        [:defeated_cthulhu,              'defeated Cthulhu', nil, 6],
        [:defeated_wizard_of_yendor,     'defeated the Wizard of Yendor', nil, 6],
        [:defeated_one_eyed_sam,         'No membership card (defeated One-Eyed Sam)', 'm-sam.png', 6],
        [:defeated_aphrodite,            'defeated Aphrodite', nil, 6],
        [:defeated_vlad_the_impaler,     'defeated Vlad the Impaler', nil, 6],
        [:defeated_oracle,               'defeated the Oracle', nil, 6],
        #[:defeated_medusa,               'defeated Medusa', nil, 6],
        #[:defeated_croesus,              'defeated Croesus', nil, 6],
        [:defeated_executioner,          'defeated the Executioner', nil, 6],
        [:defeated_durins_bane,          "defeated Durin's Bane", nil, 6],
        [:defeated_watcher_in_the_water, 'defeated the Watcher in the Water', nil, 6],
        # demons
        [:defeated_asmodeus,   'defeated Asmodeus', nil, 7],
        [:defeated_baalzebub,  'defeated Baalzebub', nil, 7],
        [:defeated_demogorgon, 'defeated Demogorgon', nil, 7],
        [:defeated_dispater,   'defeated Dispater', nil, 7],
        [:defeated_geryon,     'defeated Geryon', nil, 7],
        [:defeated_juiblex,    'defeated Juiblex', nil, 7],
        [:defeated_orcus,      'defeated Orcus', nil, 7],
        [:defeated_yeenoghu,   'defeated Yeenoghu', nil, 7],
        # quest leader
        [:defeated_lord_carnarvon,     'defeated Lord Carnarvon, the Archeologist quest leader', nil, 8],
        [:defeated_pelias,             'defeated Pelias, the Barbarian quest leader', nil, 8],
        [:defeated_shaman_karnov,      'defeated Shaman Karnov, the Caveman quest leader', nil, 8],
        [:defeated_robert_the_lifer,   'defeated Robert the Lifer, the Convict quest leader', nil, 8],
        [:defeated_hippocrates,        'defeated Hippocrates, the Healer quest leader', nil, 8],
        [:defeated_king_arthur,        'defeated King Arthur, the Knight quest leader', nil, 8],
        [:defeated_grand_master,       'defeated Grand Master, the Monk quest leader', nil, 8],
        [:defeated_arch_priest,        'defeated the Arch Priest, the Priest quest leader', nil, 8],
        [:defeated_orion,              'defeated Orion, the Ranger quest leader', nil, 8],
        [:defeated_master_of_thieves,  'defeated the Master of Thieves, the Rogue quest leader and Tourist quest nemesis', nil, 8],
        [:defeated_lord_sato,          'defeated Lord Sato, the Samurai quest leader', nil, 8],
        [:defeated_twoflower,          'defeated Twoflower, the Tourist quest leader', nil, 8],
        [:defeated_norn,               'defeated Norn, the Valkyrie quest leader', nil, 8],
        [:defeated_neferet_the_green,  'defeated Neferet the Green, the Wizard quest leader', nil, 8],
        # quest nemesis
        [:defeated_minion_of_huhetotl, 'defeated the Minion of Huhetotl, the Archeologist quest nemesis', nil, 9],
        [:defeated_thoth_amon,         'defeated Thoth Amon, the Barbarian quest nemesis', nil, 9],
        [:defeated_tiamat,             'defeated Tiamat, the Caveman quest nemesis', nil, 9],
        [:defeated_warden_arianna,     'defeated Warden Arianna, the Convict quest nemesis', nil, 9],
        [:defeated_cyclops,            'defeated Cyclops, the Healer quest nemesis', nil, 9],
        [:defeated_ixoth,              'defeated Ixoth, the Knight quest nemesis', nil, 9],
        [:defeated_master_kaen,        'defeated Master Kaen, the Monk quest nemesis', nil, 9],
        [:defeated_nalzok,             'defeated Nalzok, the Priest quest nemesis', nil, 9],
        [:defeated_scorpius,           'defeated Scorpius, the Ranger quest nemesis', nil, 9],
        [:defeated_master_assassin,    'defeated the Master Assassin, the Rogue quest nemesis', nil, 9],
        [:defeated_ashikaga_takauji,   'defeated Ashikaga Takauji, the Samurai quest nemesis', nil, 9],
        [:defeated_lord_surtur,        'defeated Lord Surtur, the Valkyrie quest nemesis', nil, 9],
        [:defeated_dark_one,           'defeated the Dark One, the Wizard quest nemesis', nil, 9],
      ]

      if variant != unnethack then
        achievements.reject! {|achievement|
          [:defeated_warden_arianna, :defeated_robert_the_lifer, :defeated_cthulhu,
           :defeated_one_eyed_sam, :defeated_executioner, :defeated_durins_bane,
           :defeated_watcher_in_the_water, :defeated_aphrodite].include? achievement[0]
        }
      end

      if [evilhack].include? variant then
        achievements << [:defeated_red_horse,   'defeated the Red Horse',   nil, 10]
        achievements << [:defeated_white_horse, 'defeated the White Horse', nil, 10]
        achievements << [:defeated_pale_horse,  'defeated the Pale Horse',  nil, 10]
        achievements << [:defeated_black_horse, 'defeated the Black Horse', nil, 10]
        achievements << [:defeated_croesus,     'Assault on Fort Knox (defeated Croesus)', 'm-croesus.png', 6]
      end

      achievements.each {|achievement|
        icon = achievement[2] || "u-#{achievement[0].to_s.gsub(' ', '_')}.png"
        Trophy.create variant: variant, trophy: achievement[0], text: achievement[1], icon: icon, row: achievement[3]
      }
    end

    if [nethack36, splicehack, xnethack, evilhack].include? variant then
      Trophy.create variant: variant, trophy: :killed_by_molochs_indifference, text: "killed by Moloch's indifference", icon: "killed_by_molochs_indifference.png", row: 2
    end

    if [nh4k].include? variant then
      Trophy.create variant: variant, trophy: "entered_the_sokoban_zoo", text: "entered the Sokoban Zoo", icon: "4k-entered-sokoban.png", row: 2
      Trophy.create variant: variant, trophy: "entered_minetown_temple", text: "entered the Minetown Temple", icon: "4k-entered-minetown-temple.png", row: 2
      Trophy.create variant: variant, trophy: "reached_mines_end", text: "reached the bottom of the Mines", icon: "4k-mines-end.png", row: 2
    end

    # DNetHack specific achievements
    if [dnethack, dnhslex].include? variant then
      Trophy.create variant: variant, trophy: "one_key", text: "That was the easy one (obtained at least one alignment key)", icon: "m-one-key.png", row: 2
      Trophy.create variant: variant, trophy: "three_keys", text: "Through the gates of Gehennom (obtained at least three alignment keys)", icon: "m-three-keys.png", row: 2
      Trophy.create variant: variant, trophy: "nine_keys", text: "Those were for replay value... (obtained all nine alignment keys)", icon: "m-nine-keys.png", row: 2
      #
      #Trophy.create variant: variant, trophy: "killed_lucifer", text: "Round two goes to you (killed Lucifer on the Astral Plane)", icon: "m-killed-lucifer.png"
      Trophy.create variant: variant, trophy: "killed_asmodeus", text: "No budget for bribes (killed Asmodeus)", icon: "m-killed-asmodeus.png", row: 3
      Trophy.create variant: variant, trophy: "killed_demogorgon", text: "Postulate Proven (killed Demogorgon, thereby proving the Lord British Postulate (if it has stats, we can kill it))", icon: "m-killed-demogorgon.png", row: 3

      Trophy.create variant: variant, trophy: "dn_king", text: "King of dNethack: Ascend a game with all the new races/roles in dNethack", icon: "m-dn-king.png", row: 4
      Trophy.create variant: variant, trophy: "dn_prince", text: "Prince of dNethack: Ascend a game with half the new races/roles in dNethack", icon: "m-dn-prince.png", row: 4
      Trophy.create variant: variant, trophy: "dn_tour", text: "dNethack Tour: Played a game (at least 1000 turns) with all the shiny new races/roles in dNethack", icon: "m-dn-tour.png", row: 4
    end

    if [slashthem, slex].include? variant then
      $slash_achievements.reject(&:empty?).each {|trophy|
        Trophy.create variant: variant, trophy: trophy[1], text: trophy[2], icon: trophy[3], row: trophy[0]
      }
    end

    if [slex].include? variant then
      $slex_extended_achievements.each {|trophy|
        Trophy.create variant: variant, trophy: trophy[1], text: trophy[2], icon: trophy[3], row: trophy[0]
      }
    end

    if [grunthack, sporkhack, splicehack].include? variant then
      Trophy.create variant: variant, trophy: "ascended_without_elbereth", text: "ascended without writing Elbereth", icon: "m-elbereth.png", row: 2
    end

    if [xnethack].include? variant then
      Trophy.create variant: variant, trophy: :ascended_without_unfairly_scaring_monsters, text: "ascended without scaring any monsters", icon: "m-elbereth.png", row: 2

      $xnethack_achievements.reject(&:empty?).each {|trophy|
        Trophy.create variant: variant, trophy: trophy[1], text: trophy[2], icon: trophy[3], row: trophy[0]
      }
    end

    if [splicehack].include? variant then
      $splicehack_achievements.reject(&:empty?).each {|trophy|
        Trophy.create variant: variant, trophy: trophy[1], text: trophy[2], icon: trophy[3], row: trophy[0]
      }
    end

    if [notdnethack].include? variant then
      achievements = [
        [:get_kroo,          "Kroo's Bling (Acquire the dismal swamp completion prize)", nil, 2],
        [:get_poplar,        "Punishing Poplars (Acquire the black forest completion prize)", nil, 2],
        [:get_abominable,    "Snowplow (Acquire the ice caves completion prize)", nil, 2],
        [:get_gilly,         "Gillywhatnow (Acquire the archipelago completion prize)", nil, 2],
        [:did_demo,          "Aameul & Hethradiah (Summon demogorgon with the forbidden ritual)", nil, 2],
        [:did_unknown,       "An Unknown Ritual (Perform the ritual of an unknown god)", nil, 2],
        [:killed_illurien,   "Angry Librarian (Kill Illurien of the Myriad Glimpses)", nil, 2],
        [:pain_duo,          "Duo of Pain (Acquire both the silver key and the cage key)", nil, 2],
        [:killed_asmodeus,   "Asmodown (Kill Asmodeus)", 'm-killed-asmodeus.png', 2],
        [:killed_demogorgon, "Demogorgone (Kill Demogorgon)", 'm-killed-demogorgon.png', 2],
        [:one_key,           "One Key (Acquire an alignment key)", 'm-one-key.png', 2],
        [:three_keys,        "Three Keys (Acquire three alignment keys)", 'm-three-keys.png', 2],
        [:anarcho_alchemist, "Anarcho-Alchemist (Make every unique alchemy kit potion in a single game)", nil, 2],
        [:used_smith,        "If The Shoe Fits... (Pay for an armorsmith service)", nil, 2],
        [:max_punch,         "Not Pulling Punches (Land a punch with all 4 offensive mystic powers active)", nil, 2],
        [:garnet_spear,      "Garnet Rod (Land a hit with a garnet tipped spear)", nil, 2],
        [:half_overload,     "Chernobyl (Cast a spell 150% overloaded or higher)", nil, 2],
      ]
      achievements.each {|achievement|
        icon = achievement[2] || "#{achievement[0].to_s.gsub(' ', '_')}.png"
        Trophy.create variant: variant, trophy: achievement[0], text: achievement[1], icon: icon, row: achievement[3]
      }
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

  # verify that every Trophy has existing icons
  Trophy.all.each {|trophy|
    raise "Trophy icon #{trophy.icon} doesn't exist" unless File.exist? "icons/#{trophy.icon}"
    raise "Trophy icon #{trophy.light_icon} doesn't exist" unless File.exist? "icons/#{trophy.light_icon}"
  }
end

DataMapper::MigrationRunner.migration( 1, :create_trophy_achievements_indexes ) do
  up do
    execute 'CREATE UNIQUE INDEX "unique_trophy_variant" ON "trophies" ("variant", "trophy");'
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
    #Trophy.create :variant => "clan", :trophy => "most_log_points", :text => "Most logarithmic points", :icon => "clan-points.png"

    # new clan trophies in 2018
    Trophy.create variant: :clan, trophy: :lowest_turns_for_monster_kills, text: "Lowest sum of turns of getting killed by specific monsters", icon: "clan-lowest-turns-for-monster-kills.png"
  end
end

DataMapper::MigrationRunner.migration( 3, :create_variant_trophies ) do
  up do
    # add all already existing variants
    Trophy.check_trophies_for_variant "vanilla"
    Trophy.check_trophies_for_variant "3.6.0"
    Trophy.check_trophies_for_variant "sporkhack"
    Trophy.check_trophies_for_variant "unnethack"
    Trophy.check_trophies_for_variant "grunthack"
    Trophy.check_trophies_for_variant "nethack4"
    Trophy.check_trophies_for_variant "dnethack"
    Trophy.check_trophies_for_variant "nethack fourk"
    Trophy.check_trophies_for_variant "fiqhack"
    Trophy.check_trophies_for_variant "dynahack"
    Trophy.check_trophies_for_variant "slash'em extended"
    Trophy.check_trophies_for_variant "xnethack"
    Trophy.check_trophies_for_variant "splicehack"
    Trophy.check_trophies_for_variant "evilhack"
    Trophy.check_trophies_for_variant "dnethack slex"
    Trophy.check_trophies_for_variant "notdnethack"
    Trophy.check_trophies_for_variant "oldhack"
  end
end
