require 'userscore'
require 'trophyscore'
require 'normalize_death'

# This one returns last games ordered by endtime, with the latest game
# first.
# Optionally give conditions and limit.
def get_last_games(condition={}, limit=10)
  Game.where(condition).order(endtime: :desc).limit(limit)
end

# This one returns users ordered by the number of ascensions they have
def most_ascensions_users(user=nil)
  if user then
    sql_select("select count(1) as ascensions, (select name from users where id=user_id) as name from games where death='ascended' and user_id = ? group by user_id order by count(1) desc;", user)
  else
    sql_select("select count(1) as ascensions, (select name from users where id=user_id) as name from games where death='ascended' and user_id is not null group by user_id order by count(1) desc;")
  end
end

def best_sustained_ascension_rate(and_collection=nil)
  games = sql_select("select endtime, (select login from users where id = user_id) as user, death, name from games where user_id is not null order by user_id, endtime asc;")
  score = Hash.new(0)
  games.each {|g|
    d = g[:death]=='ascended' ? 1 : -1
    score[g[:user]] += d
    score[g[:user]] = 0 if score[g[:user]] < 0
  }
  score = score.delete_if {|key, value| value == 0 }
  score.sort_by{|_, score| -score}
end

## Cross Variant Achievements
# King of the world: ascend in all variants
def count_ascended_variants(user)
  anz = sql_select_values("select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and ascended = true;", user)
  anz[0]
end

# Sightseeing tour: finish a game in all variants (die after at least 1000 turns or ascend)
def count_sightseeing_tour(user)
  anz = sql_select_values("select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and turns >= 1000;", user)
  anz[0]
end

#  Globetrotter: get a trophy for each variant
def count_globetrotter(user)
  anz = sql_select_values("select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d';", user)
  anz[0]
end

# Anti-Stoner: defeat Medusa in each variant
def count_anti_stoner(user)
  anz = sql_select_values("select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d' and trophy='defeated_medusa';", user)
  anz[0]
end

# dNetHack
$dNetHack_races = "race in ('Inc','Clk','Dro','Hlf')"
$dNetHack_roles = "role in ('Nob','Pir','Bin','Brd', 'Ana', 'Con')"
def dnethack_tour?(user)
  anz = sql_select_values("SELECT count(1) FROM (SELECT DISTINCT race FROM games WHERE user_id = ? AND version = 'dnh' AND turns >= 1000 AND #{$dNetHack_races} UNION SELECT DISTINCT role FROM games WHERE user_id = ? AND version = 'dnh' AND turns >= 1000 AND #{$dNetHack_roles}) a;", user, user)[0]
  return anz == 10
end

def dnethack_one_hellish_seal?(user)
  seals = Game.where(user_id: user).pluck(:achieve_x).map { |g| (g||"").split(",") }.flatten
  (seals & ["angel_hell_vault", "ancient_hell_vault", "tanninim_hell_vault"]).size >= 1
end

def dnethack_all_hellish_seals?(user)
  seals = Game.where(user_id: user).pluck(:achieve_x).map { |g| (g||"").split(",") }.flatten
  (seals & ["angel_hell_vault", "ancient_hell_vault", "tanninim_hell_vault"]).size >= 3
end

def dnethack_king?(user)
  anz = sql_select_values("SELECT count(1) FROM (SELECT DISTINCT race FROM games WHERE user_id = ? AND version = 'dnh' AND ascended = true AND #{$dNetHack_races} UNION SELECT DISTINCT role FROM games WHERE user_id = ? AND version = 'dnh' AND ascended = true AND #{$dNetHack_roles}) a;", user, user)[0]
  return anz == 10
end

def dnethack_prince?(user)
  anz = sql_select_values("SELECT count(1) FROM (SELECT DISTINCT race FROM games WHERE user_id = ? AND version = 'dnh' AND ascended = true AND #{$dNetHack_races} UNION SELECT DISTINCT role FROM games WHERE user_id = ? AND version = 'dnh' AND ascended = true AND #{$dNetHack_roles}) a;", user, user)[0]
  return anz >= 5
end

def update_scores(game)
  return true if not game.user_id

  t = TrophyScore.new
  if game.version != 'NH-1.3d' then
    if game.ascended
      # ascended
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: :ascended)

      Scoreentry.where(variant: game.version,
                     trophy: :most_ascensions).delete_all
      t.most_ascensions(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.ascension.to_s,
                          endtime: e.endtime,
                          trophy:  :most_ascensions)
      end

      Scoreentry.where(variant: game.version,
                     trophy: :highest_scoring_ascension).delete_all
      t.highest_scoring_ascension(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.points.to_s,
                          endtime: e.endtime,
                          trophy:  :highest_scoring_ascension)
      end

      Scoreentry.where(variant: game.version,
                     trophy: :lowest_scoring_ascension).delete_all
      t.lowest_scoring_ascension(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.points.to_s,
                          endtime: e.endtime,
                          trophy: :lowest_scoring_ascension)
      end

      Scoreentry.where(variant: game.version,
                     trophy: :fastest_ascension_realtime).delete_all
      t.fastest_ascension_realtime(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.duration.to_s,
                          value_display: parse_seconds(e.duration),
                          endtime: e.endtime,
                          trophy: :fastest_ascension_realtime)
      end

      Scoreentry.where(variant: game.version,
                     trophy: :fastest_ascension_gametime).delete_all
      t.fastest_ascension_gametime(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.duration.to_s,
                          endtime: e.endtime,
                          trophy: :fastest_ascension_gametime)
      end

      Scoreentry.where(variant: game.version,
                     trophy: :longest_ascension_streaks).delete_all
      t.longest_ascension_streaks(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.streaks.to_s,
                          endtime: e.endtime,
                          trophy: :longest_ascension_streaks)
      end

      ## Ascension Individual trophies
      # Ascended how many different variants
      if game.ascended
        (1..count_ascended_variants(game.user_id)).each {|i|
          Individualtrophy.add(game.user_id,
                               "ascended_variants_#{i}".to_sym,
                               "ascended_variants_#{i}.png")
        }
      end

      update_competition_scores_ascended(game)

      update_all_stuff(game)
    end

    # achievements
    achievements = game.achieve.hex if game.achieve
    if achievements and achievements > 0 then
      for i in 0..$achievements.size-1 do
        if achievements & 2**i > 0 then
          entry = Scoreentry.find_by(user_id: game.user_id,
                                     variant: game.version,
                                     trophy:  $achievements[i][0])
          if not entry then
            Scoreentry.create(user_id: game.user_id,
                              variant: game.version,
                              value:   "1",
                              endtime: game.endtime,
                              trophy: $achievements[i][0])
          end
        end
      end
    end
    ## Non-Ascension non-devnull achievement
    # escaped in celestial disgrace
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :escapologist) if game.escapologist?
  end

  killed_uniques = (game.killed_uniques||'').split(',').map {|unique|
    "defeated_#{unique.downcase.gsub(/[- ]/, '_').gsub("'",'')}"
  }
  generic_achievements(game, killed_uniques)

  if game.version == 'NH-1.3d' then
    ## NetHack 1.3d specific trophies
    # escaped (with the amulet)
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :ascended_old) if game.event_ascended?
    # got crowned
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :crowned) if game.got_crowned?
    # entered hell
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :entered_hell) if game.entered_hell?
    # defeated rodney
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :defeated_old_rodney) if game.defeated_rodney?
  else
    ## AceHack and UnNetHack-specific trophies
    # Too good for quests
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :ascended_without_defeating_nemesis) if game.ascended_without_defeating_nemesis?
    # Too good for Vladbanes
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :ascended_without_defeating_vlad) if game.ascended_without_defeating_vlad?
    # Too good for... wait, what? How?
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :ascended_without_defeating_rodney) if game.ascended_without_defeating_rodney?
    # Too good for a brain
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :ascended_without_defeating_cthulhu) if game.ascended_without_defeating_cthulhu?
    # Hoarder
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :ascended_with_all_invocation_items) if game.ascended_with_all_invocation_items?
    # Assault on Fort Knox
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :defeated_croesus) if game.defeated_croesus?
    # No membership card
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :defeated_one_eyed_sam) if game.defeated_one_eyed_sam?
    # Heaven or Hell
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :heaven_or_hell) if game.ascended_heaven_or_hell?
    # Mini-Croesus
    if Trophy.find_by(variant: game.version, trophy: :mini_croesus)
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: :mini_croesus) if game.mini_croesus?
    end
    # Croesus' Buddy
    if Trophy.find_by(variant: game.version, trophy: :croesus_buddy)
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: :croesus_buddy) if game.croesus_buddy?
    end
    # Better than Croesus
    if Trophy.find_by(variant: game.version, trophy: :better_than_croesus)
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: :better_than_croesus) if game.better_than_croesus?
    end
  end

  # variant specific trophies
  acehack = helper_get_variant_for 'acehack'
  nethack4 = helper_get_variant_for 'nethack4'
  nh4k = helper_get_variant_for 'nethack fourk'
  dynahack = helper_get_variant_for 'dynahack'
  fiqhack = helper_get_variant_for 'fiqhack'
  unnethack = helper_get_variant_for 'unnethack'
  grunthack = helper_get_variant_for 'grunthack'
  sporkhack = helper_get_variant_for 'sporkhack'
  splicehack = helper_get_variant_for 'splicehack'
  xnethack = helper_get_variant_for 'xnethack'
  nethack36 = helper_get_variant_for '3.6.1'
  evilhack = helper_get_variant_for 'evilhack'
  crecellehack = helper_get_variant_for 'crecellehack'

  ## specific trophies as they don't track xlogfile achievements
  if [acehack, nethack4, nh4k, dynahack, fiqhack].include? game.version then
    # bought an Oracle consultation
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :bought_oracle_consultation) if game.event_bought_oracle_consultation?
    # reached the quest portal level
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :accepted_for_quest) if game.event_accepted_for_quest?
    # defeated the quest nemesis
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :defeated_quest_nemesis) if game.event_defeated_quest_nemesis?
    # defeated Medusa
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :defeated_medusa) if game.event_defeated_medusa?
    # entered Gehennom the front way
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :event_entered_gehennom_front_way) if game.event_entered_gehennom_front_way?
    # defeated Vlad
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :defeated_vlad) if game.event_defeated_vlad?
    # defeated Rodney at least once
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :defeated_rodney) if game.event_defeated_rodney?
    # did the invocation
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :performed_the_invocation_ritual) if game.event_did_invocation?
    # defeated a high priest
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :defeated_a_high_priest) if game.event_defeated_a_high_priest?
    # entered the planes
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :entered_elemental_planes) if game.entered_planes?
    # entered astral
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :entered_astral_plane) if game.entered_astral?
    # ascended without Elbereth
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :ascended_without_elbereth) if game.ascended_without_elbereth?
  end

  if [unnethack, grunthack, sporkhack, splicehack, evilhack].include? game.version then
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :ascended_without_elbereth) if game.ascended_without_elbereth?
  end

  if [xnethack].include? game.version then
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :completed_arc_quest) if game.role == "Arc" && game.completed_quest?
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :completed_val_quest) if game.role == "Val" && game.completed_quest?
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :ascended_without_unfairly_scaring_monsters) if game.ascended_without_unfairly_scaring_monsters?
  end

  if [unnethack, evilhack].include? game.version then
    if game.event_bought_oracle_consultation?
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: :bought_oracle_consultation)
    end

    if defeated_all_riders?(game)
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: :defeated_all_riders)
    end

    if defeated_all_demon_lords_princes?(game)
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: :defeated_all_demon_lords_princes)
    end

    if defeated_all_quest_leaders?(game)
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: :defeated_all_quest_leaders)
    end

    if defeated_all_quest_nemeses?(game)
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: :defeated_all_quest_nemeses)
    end
  end

  if Trophy.exists_for_variant?(game.version, :killed_by_molochs_indifference)
    if game.killed_by_molochs_indifference?
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: :killed_by_molochs_indifference)
    end
  end

  # DNetHack specific trophies
  dnethack = helper_get_variant_for 'dnethack'
  notdnethack = helper_get_variant_for 'notdnethack'
  notnotdnethack = helper_get_variant_for 'notnotdnethack'
  dnhslex = helper_get_variant_for 'dnethack slex'
  if [dnethack, dnhslex, notdnethack, notnotdnethack].include? game.version then
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :one_key) if game.got_one_key?
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :three_keys) if game.got_three_keys?
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :nine_keys) if game.got_nine_keys?
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :dn_tour) if dnethack_tour? game.user_id
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :opened_one_hellish_seal) if dnethack_one_hellish_seal? game.user_id
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :opened_all_hellish_seals) if dnethack_all_hellish_seals? game.user_id
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :killed_asmodeus) if game.dnethack_defeated_asmodeus?
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :killed_demogorgon) if game.dnethack_defeated_demogorgon?
  end

  # NetHack Fourk specific trophies
  if nh4k == game.version then
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :entered_the_sokoban_zoo) if game.entered_the_sokoban_zoo?
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :entered_minetown_temple) if game.entered_minetown_temple?
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :reached_mines_end) if game.reached_mines_end?
  end

  slashthem = helper_get_variant_for 'slashthem'
  slex = helper_get_variant_for "slash'em extended"
  if [slex, slashthem].include? game.version then
    achievements = game.achieve.hex if game.achieve
    if achievements and achievements > 0 then
      for i in 12..$slash_achievements.size-1 do
        if achievements & 2**i > 0 then
          entry = Scoreentry.find_by(user_id: game.user_id,
                                     variant: game.version,
                                     trophy: $slash_achievements[i][1])
          if not entry then
            Scoreentry.create(user_id: game.user_id,
                              variant: game.version,
                              value: "1",
                              endtime: game.endtime,
                              trophy: $slash_achievements[i][1])
          end
        end
      end
    end
  end

  if game.achieve_x then
    generic_achievements(game, (game.achieve_x||'').split(','))
  end

  if game.ascended && [xnethack].include?(game.version)
    conducts = game.conduct_x&.split(",")
    [
      [:ascended_petless,      "petless"],
      [:ascended_artifactless, "artifactless"],
      [:ascended_permahallu,   "permahallu"],
      [:ascended_permadeaf,    "permadeaf"],
    ].each { |trophy, conduct|
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: trophy) if conducts.include?(conduct)
    }
  end

  if [crecellehack].include?(game.version) then
    generic_achievements(game, (game.conduct_x||'').split(','))

    if game.ascended
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                    variant: game.version,
                                    trophy: :ascended_kobold) if game.race == 'Kobold'
      Scoreentry.find_or_create_by(user_id: game.user_id,
                                    variant: game.version,
                                    trophy: :ascended_grappler) if game.role == 'Grp'
    end
  end

  if game.ascended && [evilhack].include?(game.version) then
    achievements = game.conduct.hex if game.conduct
    if achievements and achievements > 0 then
      for i in 0..$xnethack_achievements.size-1 do
        next if $xnethack_achievements[i].empty?
        if achievements & 2**(i+12) > 0 then
          entry = Scoreentry.find_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: $xnethack_achievements[i][1])
          if not entry then
            Scoreentry.create(user_id: game.user_id,
                              variant: game.version,
                              value: "1",
                              endtime: game.endtime,
                              trophy: $xnethack_achievements[i][1])
          end
        end
      end
    end
  end

  if [splicehack].include?(game.version) then
    achievements = game.achieve.hex if game.achieve
    if achievements and achievements > 0 then
      for i in 0..$splicehack_achievements.size-1 do
        next if $splicehack_achievements[i].empty?
        next if $splicehack_achievements[i][1].to_s.start_with?('ascended_') && !game.ascended
        if achievements & 2**(i+14) > 0 then
          entry = Scoreentry.find_by(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: $splicehack_achievements[i][1])
          if not entry then
            Scoreentry.create(user_id: game.user_id,
                              variant: game.version,
                              value: "1",
                              endtime: game.endtime,
                              trophy: $splicehack_achievements[i][1])
          end
        end
      end
    end
  end

  if [unnethack].include? game.version then
    Scoreentry.find_or_create_by(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :ascended_marathon) if game.ascended? && game.mode == 'marathon'
  end

  ## Non-Ascension cross-variant trophies
  # Sightseeing tour: finish a game in n variants
  (1..count_sightseeing_tour(game.user_id)).each {|index|
    Individualtrophy.add(game.user_id,
                         "sightseeing_tour_#{index}".to_sym,
                         "sightseeing_tour_#{index}.png")
  }

  # Anti-Stoner: defeat Medusa in n variants
  (1..count_anti_stoner(game.user_id)).each {|index|
    Individualtrophy.add(game.user_id,
                         "anti_stoner_#{index}".to_sym,
                         "anti_stoner_#{index}.png")
  }

  # Globetrotter: get a trophy in n variants
  (1..count_globetrotter(game.user_id)).each {|index|
    Individualtrophy.add(game.user_id,
                         "globetrotter_#{index}".to_sym,
                         "globetrotter_#{index}.png")
  }

  return false if not local_normalize_death(game)

  return false if not update_clan_scores(game)
end

def generic_achievements(game, achievements)
  achievements.each { |achievement|
    if Trophy.find_by(variant: game.version, trophy: achievement)
      entry = Scoreentry.find_by(user_id: game.user_id,
                               variant: game.version,
                               trophy:  achievement)
      if not entry then
        Scoreentry.create(user_id: game.user_id,
                          variant: game.version,
                          value:   1,
                          endtime: game.endtime,
                          trophy:  achievement)
      end
    end
  }
end

def local_normalize_death(game)
  normalized_death = NormalizedDeath.find_or_initialize_by(game_id: game.id)
  normalized_death.death = game.normalize_death
  normalized_death.monster = game.normalize_monster
  normalized_death.user_id = game.user_id
  normalized_death.save
end

def ascended_combinations_user_sql
  "SELECT DISTINCT version, role, race, align0, gender0 from games where ascended = true and user_id = ?"
end
def ascended_combinations_sql
  "SELECT DISTINCT version, role, race, align0, gender0 from games where ascended = true and user_id in (SELECT id FROM users WHERE clan_name = ?)"
end
def unique_deaths_sql
  "SELECT DISTINCT death from normalized_deaths where user_id in (SELECT id FROM users WHERE clan_name = ?)"
end

def variant_trophy_combinations_sql
  "SELECT DISTINCT variant, trophy from (SELECT user_id, variant, trophy from scoreentries UNION SELECT user_id, variant, trophy from competition_score_entries where rank = 1) scoreentriees where user_id in (SELECT id FROM users WHERE clan_name = ?)"
end
def variant_trophy_combinations_user_sql
  "SELECT DISTINCT variant, trophy from (SELECT user_id, variant, trophy from scoreentries UNION SELECT user_id, variant, trophy from competition_score_entries = 1) where user_id = ?"
end

def most_ascensions_in_a_24_hour_period(clan)
  clan_endtimes = sql_select("SELECT * FROM (SELECT (SELECT clan_name FROM users WHERE user_id = id) AS clan, endtime, endtime+86400 AS endtime_end FROM games WHERE ascended = true AND user_id IS NOT NULL) games WHERE clan = ? ORDER BY endtime", clan)

  max_ascensions = 0
  clan_endtimes.each do |e|
    ascensions = sql_select_values("select count(1) from games where (select clan_name from users where user_id = id) = ? and ascended = true and endtime >= ? and endtime <= ?", e.clan, e.endtime, e.endtime_end)[0]
    max_ascensions = ascensions if ascensions > max_ascensions
  end
  return max_ascensions
end

$clan_killed_by = [
  'newt',
  'dwarf',
  'soldier ant',
  'Asmodeus',
  'Croesus',
  'Izchak',
  'Medusa',
  'Oracle',
  'Vlad the Impaler',
]
def turns_killed_by_all_monsters clan_name
  clan = Clan.find_by(name: clan_name)
  users = clan.users.map(&:id)

  turns = $clan_killed_by.map {|monster|
    game_ids = NormalizedDeath.where(user_id: users, monster: monster).pluck(:game_id)
    Game.where(id: game_ids).minimum(:turns)
  }
  return nil if turns.include? nil

  turns.inject(0) {|sum,i| sum += i }
end

def update_clan_scores(game)
  return true if not game.user_id

  # Clan competition
  clan_name = User.find(game.user_id).clan_name
  if clan_name then
    most_ascended_combinations = sql_select_values("SELECT count(1) from ("+ascended_combinations_sql+") a;", clan_name)[0]
    c = ClanScoreEntry.find_or_initialize_by(clan_name: clan_name,
                                    trophy: :most_ascended_combinations)
    c.value = most_ascended_combinations
    c.save

    most_unique_deaths = sql_select_values("SELECT count(1) from ("+unique_deaths_sql+") a;", clan_name)[0]
    c = ClanScoreEntry.find_or_initialize_by(clan_name: clan_name,
                                    trophy: :most_unique_deaths)
    c.value = most_unique_deaths
    c.save

    c = ClanScoreEntry.find_or_initialize_by(clan_name: clan_name,
                                    trophy: :most_ascensions_in_a_24_hour_period)
    c.value = most_ascensions_in_a_24_hour_period clan_name
    c.save

    # This one is new for 2012.
    # We didn't have this clan trophy for the 2011 tournament.
    most_variant_trophy_combinations = sql_select_values("SELECT count(1) from ("+variant_trophy_combinations_sql+") a;", clan_name)[0]
    c = ClanScoreEntry.find_or_initialize_by(clan_name: clan_name,
                                    trophy: :most_variant_trophy_combinations)
    c.value = most_variant_trophy_combinations
    c.save

    # new clan trophies for 2013
    # Most Medusa kills
    most_medusa_kills = Game.where(user_id: User.where(clan_name: clan_name).select(:id)).sum(:killed_medusa)
    c = ClanScoreEntry.find_or_initialize_by(clan_name: clan_name,
                                    trophy: :most_medusa_kills)
    c.value = most_medusa_kills
    c.save

    # Most games with all conducts broken
    most_full_conducts_broken = sql_select_values("SELECT count(1) FROM games WHERE nconducts = 0 and user_id in (SELECT id FROM users WHERE clan_name = ?) and version != 'NH-1.3d';", clan_name)[0]
    c = ClanScoreEntry.find_or_initialize_by(clan_name: clan_name,
                                    trophy: :most_full_conducts_broken)
    c.value = most_full_conducts_broken
    c.save
  end

  rank_clans
  score_clans
  history_clans

  return true
end

def history_clans
  ClanScoreEntry.all.each {|e|
    h = ClanScoreHistory.where(trophy: e.trophy, clan_name: e.clan_name).order(created_at: :desc).first
    # only record when points or rank has changed
    if not h or h.points != e.points or h.rank != e.rank or h.value != e.value
      ClanScoreHistory.create(e.attributes.except("id"))
    end
  }
end

def rank_clans
  rank_collection(ClanScoreEntry.where(trophy: :most_ascended_combinations).order(value: :desc))
  rank_collection(ClanScoreEntry.where(trophy: :most_unique_deaths).order(value: :desc))
  rank_collection(ClanScoreEntry.where(trophy: :most_ascensions_in_a_24_hour_period).order(value: :desc))
  rank_collection(ClanScoreEntry.where(trophy: :most_variant_trophy_combinations).order(value: :desc))
  rank_collection(ClanScoreEntry.where(trophy: :most_medusa_kills).order(value: :desc))
  rank_collection(ClanScoreEntry.where(trophy: :most_full_conducts_broken).order(value: :desc))
  true
end

def score_clans
  clanscoreentries = ClanScoreEntry.where.not(trophy: 'clan_winner').order(:trophy, :rank)

  best_value = 0
  clanscoreentries.each do |c|
    best_value = c.value if c.rank == 1
    case c.rank
    when 1
      c.points = 4.0
    when 2
      c.points = 3.0
    when 3
      c.points = 2.0
    else
      if c.value == 0 then
        c.points = 0.0
      else
        # round to 2 significant figures after decimal point
        if c.value.to_f <= best_value.to_f
          c.points = (c.value.to_f / best_value.to_f).round(2)
        else
          c.points = (best_value.to_f / c.value.to_f).round(2)
        end
      end
    end
    c.save
  end

  # calculate clan points
  clan_scores = sql_select("select sum(points) as sum_points, clan_name from clan_score_entries where trophy in ('most_ascended_combinations','most_unique_deaths','most_ascensions_in_a_24_hour_period','most_variant_trophy_combinations','most_full_conducts_broken','most_medusa_kills','lowest_turns_for_monster_kills') group by clan_name")
  clan_scores.each do |clan_score|
    c = ClanScoreEntry.find_or_initialize_by(clan_name: clan_score.clan_name,
                                    trophy: :clan_winner)
    c.value = (clan_score.sum_points*100).to_i
    # round to 2 significant figures after decimal point
    c.points = clan_score.sum_points.round(2)
    c.save
  end

  rank_collection(ClanScoreEntry.where(trophy: :clan_winner).order(value: :desc))
end

# Update competition trophies for an ascended game,
# Currently there are no competition trophies for games that are not
# ascended.
def update_competition_scores_ascended(game)
  return true if not game.user_id

  u = UserScore.new(game.user_id)

  # Clan competitions
  nconducts = u.most_conducts_ascension(game.version)[0]
  c = CompetitionScoreEntry.find_or_initialize_by(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :most_conducts_ascension)
  c.value = nconducts
  c.save

  points = u.highest_scoring_ascension(game.version)[0]
  c = CompetitionScoreEntry.find_or_initialize_by(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :highest_scoring_ascension)
  c.value = points
  c.save

  points = u.lowest_scoring_ascension(game.version)[0]
  c = CompetitionScoreEntry.find_or_initialize_by(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :lowest_scoring_ascension)
  c.value = points
  c.save

  realtime = u.fastest_ascension_realtime(game.version)
  c = CompetitionScoreEntry.find_or_initialize_by(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :fastest_ascension_realtime)
  c.value = realtime
  c.save

  gametime = u.fastest_ascension_gametime(game.version)
  c = CompetitionScoreEntry.find_or_initialize_by(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :fastest_ascension_gametime)
  c.value = gametime
  c.save

  ascensions = u.most_ascensions(game.version)
  c = CompetitionScoreEntry.find_or_initialize_by(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :most_ascensions)
  c.value = ascensions
  c.save

  longest_ascension_streak = u.longest_ascension_streak(game.version)
  if longest_ascension_streak > 0 then
    c = CompetitionScoreEntry.find_or_initialize_by(user_id: game.user_id,
                                           variant: game.version,
                                           trophy: :longest_ascension_streaks)
    c.value = longest_ascension_streak
    c.save
  end

  v = game.version
  rank_collection(CompetitionScoreEntry.where(variant: v, trophy: :most_conducts_ascension).order(value: :desc))
  rank_collection(CompetitionScoreEntry.where(variant: v, trophy: :highest_scoring_ascension).order(value: :desc))
  rank_collection(CompetitionScoreEntry.where(variant: v, trophy: :lowest_scoring_ascension).order(value: :asc))
  rank_collection(CompetitionScoreEntry.where(variant: v, trophy: :fastest_ascension_realtime).order(value: :asc))
  rank_collection(CompetitionScoreEntry.where(variant: v, trophy: :fastest_ascension_gametime).order(value: :asc))
  rank_collection(CompetitionScoreEntry.where(variant: v, trophy: :most_ascensions).order(value: :desc))
  rank_collection(CompetitionScoreEntry.where(variant: v, trophy: :longest_ascension_streaks).order(value: :desc))

  return true
end

def rank_collection(collection)
  # ranking
  value = -1
  rank = 0
  collection.each {|c|
    rank += 1 unless value == c.value
    value = c.value
    c.rank = rank
    c.save
  }
end

# defeated_all_foos
def defeated_all_riders?(game)
  riders = [:defeated_death, :defeated_famine, :defeated_pestilence]
  Scoreentry.where(user_id: game.user_id,
                   variant: game.version,
                   trophy: riders).count == riders.count
end

def defeated_all_demon_lords_princes?(game)
  demons = [
    :defeated_asmodeus,
    :defeated_baalzebub,
    :defeated_demogorgon,
    :defeated_dispater,
    :defeated_geryon,
    :defeated_juiblex,
    :defeated_orcus,
    :defeated_yeenoghu,
  ]
  Scoreentry.where(user_id: game.user_id,
                   variant: game.version,
                   trophy: demons).count == demons.count

end

def defeated_all_quest_leaders?(game)
  leaders = [
    :defeated_lord_carnarvon,
    :defeated_pelias,
    :defeated_shaman_karnov,
    :defeated_hippocrates,
    :defeated_king_arthur,
    :defeated_grand_master,
    :defeated_arch_priest,
    :defeated_orion,
    :defeated_master_of_thieves,
    :defeated_lord_sato,
    :defeated_twoflower,
    :defeated_norn,
    :defeated_neferet_the_green,
  ]

  unnethack = helper_get_variant_for 'unnethack'
  if game.version == unnethack
    leaders << :defeated_robert_the_lifer
  end
  Scoreentry.where(user_id: game.user_id,
                   variant: game.version,
                   trophy: leaders).count == leaders.count
end

def defeated_all_quest_nemeses?(game)
  nemeses = [
    :defeated_thoth_amon,
    :defeated_tiamat,
    :defeated_cyclops,
    :defeated_ixoth,
    :defeated_master_kaen,
    :defeated_nalzok,
    :defeated_scorpius,
    :defeated_master_assassin,
    :defeated_ashikaga_takauji,
    :defeated_lord_surtur,
    :defeated_dark_one,
  ]

  unnethack = helper_get_variant_for 'unnethack'
  evilhack = helper_get_variant_for 'evilhack'
  if game.version == unnethack
    nemeses << :defeated_warden_arianna
    nemeses << :defeated_schliemann
  elsif game.version == evilhack
    nemeses << :defeated_minion_of_huhetotl
  end
  Scoreentry.where(user_id: game.user_id,
                   variant: game.version,
                   trophy: nemeses).count == nemeses.count
end

# All conducts: follow each conduct in at least one ascension.
def all_conducts?(user_id, variant)
  conducts = sql_select_values("select conduct from games where version = ? and user_id = ? and ascended = true;", variant, user_id)

  # bit-or all conduct integers to find out if all 12 conducts have been followed overall
  aggregated_conducts = 0
  conducts.each { |c| aggregated_conducts |= (Integer c) }

  aggregated_conducts &= 2**12-1; # limit to vanilla conducts

  return aggregated_conducts == 2**12-1
end
def all_conducts_streak?(user_id, variant)
  all_stuff_streak "nconducts", 12, user_id, variant
end

# All roles: ascend a character for each role.
def all_roles?(user_id, variant)
  anz = sql_select_values("select count(distinct role) from games where version = ? and user_id = ? and ascended = true;", variant, user_id)
  return anz[0] >= 13
end
def all_roles_streak?(user_id, variant)
  all_stuff_streak "role", 13, user_id, variant
end

# All races: ascend a character of every race.
def all_races?(user_id, variant)
  anz = sql_select_values("select count(distinct race) from games where version = ? and user_id = ? and ascended = true;", variant, user_id)
  return anz[0] == 5
end
def all_races_streak?(user_id, variant)
  all_stuff_streak "race", 5, user_id, variant
end

# All alignments: ascend a character of every alignment (the starting alignment is considered).
def all_alignments?(user_id, variant)
  anz = sql_select_values("select count(distinct align0) from games where version = ? and user_id = ? and ascended = true;", variant, user_id)
  return anz[0] == 3
end
def all_alignments_streak?(user_id, variant)
  all_stuff_streak "align0", 3, user_id, variant
end

# All genders: ascend a character of each gender (the starting gender is considered).
def all_genders?(user_id, variant)
  anz = sql_select_values("select count(distinct gender0) from games where version = ? and user_id = ? and ascended = true", variant, user_id)
  return anz[0] == 2
end
def all_genders_streak?(user_id, variant)
  all_stuff_streak "gender0", 2, user_id, variant
end

def all_stuff_streak(column, len, user_id, variant)
  games = sql_select("select * from (select "+column+" as column,ascended,endtime from games where version = ? and user_id = ? union all select "+column+" as column,ascended,endtime from start_scummed_games where version = ? and user_id = ?) order by endtime desc;", variant, user_id, variant, user_id)

  distinct_values = {}
  games.each {|game|
    if game.ascended
      distinct_values[game.column] = 1
    else
      distinct_values = {}
    end
    return true if distinct_values.keys.size == len
  }
  return false
end

def update_all_stuff(game)
  return true if not game.user_id and not game.ascended

  Scoreentry.find_or_create_by(user_id: game.user_id,
                               variant: game.version,
                               trophy: :all_conducts) if all_conducts? game.user_id, game.version
  Scoreentry.find_or_create_by(user_id: game.user_id,
                               variant: game.version,
                               trophy: :all_roles) if all_roles? game.user_id, game.version
  Scoreentry.find_or_create_by(user_id: game.user_id,
                               variant: game.version,
                               trophy: :all_races) if all_races? game.user_id, game.version
  Scoreentry.find_or_create_by(user_id: game.user_id,
                               variant: game.version,
                               trophy: :all_alignments) if all_alignments? game.user_id, game.version
  Scoreentry.find_or_create_by(user_id: game.user_id,
                               variant: game.version,
                               trophy: :all_genders) if all_genders? game.user_id, game.version
end
