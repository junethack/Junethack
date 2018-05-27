require 'userscore'
require 'trophyscore'
require 'normalize_death'

# This one returns last games ordered by endtime, with the latest game
# first.
# Optionally give conditions and limit.
def get_last_games(condition={}, limit=10)
  Game.all({ order: :endtime.desc, limit: limit}.merge condition )
end

# This one returns users ordered by the number of ascensions they have
def most_ascensions_users(user=nil)
  if user then
    repository.adapter.select "select count(1) as ascensions, (select name from users where id=user_id) as name from games where death='ascended' and user_id = ? group by user_id order by count(1) desc;", user
  else
    repository.adapter.select "select count(1) as ascensions, (select name from users where id=user_id) as name from games where death='ascended' and user_id is not null group by user_id order by count(1) desc;"
  end
end

def best_sustained_ascension_rate(and_collection=nil)
  games = repository.adapter.select "select endtime, (select login from users where id = user_id) as user, death, name from games where user_id is not null order by user_id, endtime asc;"
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
def king_of_the_world?(user)
  anz = repository.adapter.select "select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and ascended='t';", user
  return anz[0] == $variant_order.size
end

def prince_of_the_world?(user)
  anz = repository.adapter.select "select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and ascended='t';", user
  return anz[0] >= ($variant_order.size/2)
end

# Sightseeing tour: finish a game in all variants (die after at least 1000 turns or ascend)
def sightseeing_tour?(user)
  anz = repository.adapter.select "select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and turns >= 1000;", user
  return anz[0] == $variant_order.size
end
# Walk In The Park: finish a game in half of the variants
def walk_in_the_park?(user)
  anz = repository.adapter.select "select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and turns >= 1000;", user
  return anz[0] >= ($variant_order.size/2)
end


#  Globetrotter: get a trophy for each variant
def globetrotter?(user)
  anz = repository.adapter.select "select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d';", user
  return anz[0] == $variant_order.size
end
# Backpacking tourist: get a trophy for half of the variants
def backpacking_tourist?(user)
  anz = repository.adapter.select "select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d';", user
  return anz[0] >= ($variant_order.size/2)
end

# Anti-Stoner: defeat Medusa in each variant
def anti_stoner?(user)
  anz = repository.adapter.select "select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d' and trophy='defeated_medusa';", user
  return anz[0] == $variant_order.size
end
# Hemi-Stoner: defeat Medusa in half of the variants
def hemi_stoner?(user)
  anz = repository.adapter.select "select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d' and trophy='defeated_medusa';", user
  return anz[0] >= ($variant_order.size/2)
end

# dNetHack
$dNetHack_races = "race in ('Inc','Clk','Dro','Hlf')"
$dNetHack_roles = "role in ('Nob','Pir','Bin','Brd', 'Ana', 'Con')"
def dnethack_tour?(user)
  anz = repository.adapter.select("SELECT count(1) FROM (SELECT DISTINCT race FROM games WHERE user_id = ? AND version = 'dnh' AND turns >= 1000 AND #{$dNetHack_races} UNION SELECT DISTINCT role FROM games WHERE user_id = ? AND version = 'dnh' AND turns >= 1000 AND #{$dNetHack_roles}) a;", user, user)[0]
  return anz == 10
end

def dnethack_king?(user)
  anz = repository.adapter.select("SELECT count(1) FROM (SELECT DISTINCT race FROM games WHERE user_id = ? AND version = 'dnh' AND ascended='t' AND #{$dNetHack_races} UNION SELECT DISTINCT role FROM games WHERE user_id = ? AND version = 'dnh' AND ascended='t' AND #{$dNetHack_roles}) a;", user, user)[0]
  return anz == 10
end

def dnethack_prince?(user)
  anz = repository.adapter.select("SELECT count(1) FROM (SELECT DISTINCT race FROM games WHERE user_id = ? AND version = 'dnh' AND ascended='t' AND #{$dNetHack_races} UNION SELECT DISTINCT role FROM games WHERE user_id = ? AND version = 'dnh' AND ascended='t' AND #{$dNetHack_roles}) a;", user, user)[0]
  return anz >= 5
end

def update_scores(game)
  return true if not game.user_id

  t = TrophyScore.new
  if game.version != 'NH-1.3d' then
    if game.ascended
      # ascended
      Scoreentry.first_or_create(user_id: game.user_id,
                                 variant: game.version,
                                 trophy: :ascended).save

      Scoreentry.all(variant: game.version,
                     trophy: :most_ascensions).destroy
      t.most_ascensions(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.ascension.to_s,
                          endtime: e.endtime,
                          trophy:  :most_ascensions).save
      end

      Scoreentry.all(variant: game.version,
                     trophy: :highest_scoring_ascension).destroy
      t.highest_scoring_ascension(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.points.to_s,
                          endtime: e.endtime,
                          trophy:  :highest_scoring_ascension).save
      end

      Scoreentry.all(variant: game.version,
                     trophy: :lowest_scoring_ascension).destroy
      t.lowest_scoring_ascension(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.points.to_s,
                          endtime: e.endtime,
                          trophy: :lowest_scoring_ascension).save
      end

      Scoreentry.all(variant: game.version,
                     trophy: :fastest_ascension_realtime).destroy
      t.fastest_ascension_realtime(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.duration.to_s,
                          value_display: parse_seconds(e.duration),
                          endtime: e.endtime,
                          trophy: :fastest_ascension_realtime).save
      end

      Scoreentry.all(variant: game.version,
                     trophy: :fastest_ascension_gametime).destroy
      t.fastest_ascension_gametime(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.duration.to_s,
                          endtime: e.endtime,
                          trophy: :fastest_ascension_gametime).save
      end

      Scoreentry.all(variant: game.version,
                     trophy: :longest_ascension_streaks).destroy
      t.longest_ascension_streaks(game.version).each do |e|
        Scoreentry.create(user_id: e.user_id,
                          variant: game.version,
                          value:   e.streaks.to_s,
                          endtime: e.endtime,
                          trophy: :longest_ascension_streaks).save
      end

      ## Ascension Individual trophies
      # King of the World: ascend in all variants
      Individualtrophy.add(game.user_id, "King of the World",
                           :king_of_the_world, "king.png") if king_of_the_world? game.user_id
      # Prince of the World: ascend in half of the variants
      Individualtrophy.add(game.user_id, "Prince of the World",
                           :prince_of_the_world, "prince.png") if prince_of_the_world? game.user_id

      update_competition_scores_ascended(game)

      update_all_stuff(game)
    end

    # achievements
    achievements = game.achieve.hex if game.achieve
    if achievements and achievements > 0 then
      for i in 0..$achievements.size-1 do
        if achievements & 2**i > 0 then
          entry = Scoreentry.first(user_id: game.user_id,
                                   variant: game.version,
                                   trophy:  $achievements[i][0])
          if not entry then
            Scoreentry.create(user_id: game.user_id,
                              variant: game.version,
                              value:   "1",
                              endtime: game.endtime,
                              trophy: $achievements[i][0]).save
          end
        end
      end
    end
    ## Non-Ascension non-devnull achievement
    # escaped in celestial disgrace
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :escapologist).save if game.escapologist?
  end

  killed_uniques = (game.killed_uniques||'').split(',').map {|unique|
    "defeated_#{unique.downcase.gsub(' ', '_')}"
  }
  generic_achievements(game, killed_uniques)

  if game.version == 'NH-1.3d' then
    ## NetHack 1.3d specific trophies
    # escaped (with the amulet)
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :ascended_old
                              ).save if game.event_ascended?
    # got crowned
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :crowned
                              ).save if game.got_crowned?
    # entered hell
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :entered_hell
                              ).save if game.entered_hell?
    # defeated rodney
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :defeated_old_rodney
                              ).save if game.defeated_rodney?
  else
    ## AceHack and UnNetHack-specific trophies
    # Too good for quests
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :ascended_without_defeating_nemesis
                              ).save if game.ascended_without_defeating_nemesis?
    # Too good for Vladbanes
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :ascended_without_defeating_vlad
                              ).save if game.ascended_without_defeating_vlad?
    # Too good for... wait, what? How?
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :ascended_without_defeating_rodney
                              ).save if game.ascended_without_defeating_rodney?
    # Too good for a brain
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :ascended_without_defeating_cthulhu
                              ).save if game.ascended_without_defeating_cthulhu?
    # Hoarder
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :ascended_with_all_invocation_items
                              ).save if game.ascended_with_all_invocation_items?
    # Assault on Fort Knox
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :defeated_croesus
                              ).save if game.defeated_croesus?
    # No membership card
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :defeated_one_eyed_sam
                              ).save if game.defeated_one_eyed_sam?
    # Heaven or Hell
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :heaven_or_hell
                              ).save if game.ascended_heaven_or_hell?
    # Mini-Croesus
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :mini_croesus
                              ).save if game.mini_croesus?
    # Better than Croesus
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :better_than_croesus
                              ).save if game.better_than_croesus?
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

  if [acehack, nethack4, nh4k, dynahack, fiqhack].include? game.version then
    ## specific trophies as they don't track xlogfile achievements
    # bought an Oracle consultation
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :bought_oracle_consultation
                              ).save if game.event_bought_oracle_consultation?
    # reached the quest portal level
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :accepted_for_quest
                              ).save if game.event_accepted_for_quest?
    # defeated the quest nemesis
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :defeated_quest_nemesis
                              ).save if game.event_defeated_quest_nemesis?
    # defeated Medusa
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :defeated_medusa
                              ).save if game.event_defeated_medusa?
    # entered Gehennom the front way
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :event_entered_gehennom_front_way
                              ).save if game.event_entered_gehennom_front_way?
    # defeated Vlad
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :defeated_vlad
                              ).save if game.event_defeated_vlad?
    # defeated Rodney at least once
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :defeated_rodney
                              ).save if game.event_defeated_rodney?
    # did the invocation
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :performed_the_invocation_ritual
                              ).save if game.event_did_invocation?
    # defeated a high priest
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :defeated_a_high_priest
                              ).save if game.event_defeated_a_high_priest?
    # entered the planes
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :entered_elemental_planes
                              ).save if game.entered_planes?
    # entered astral
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :entered_astral_plane
                              ).save if game.entered_astral?
    # ascended without Elbereth astral
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :ascended_without_elbereth
                              ).save if game.ascended_without_elbereth?
  end

  if [unnethack, grunthack, sporkhack, splicehack].include? game.version then
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :ascended_without_elbereth
                              ).save if game.ascended_without_elbereth?
  end

  if [xnethack].include? game.version then
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :ascended_without_unfairly_scaring_monsters
                              ).save if game.ascended_without_unfairly_scaring_monsters?
  end

  if [unnethack].include? game.version then
    if game.event_bought_oracle_consultation?
      Scoreentry.first_or_create(user_id: game.user_id,
                                 variant: game.version,
                                 trophy:  :bought_oracle_consultation).save
    end

    if defeated_all_riders?(game)
      Scoreentry.first_or_create(user_id: game.user_id,
                                 variant: game.version,
                                 trophy:  :defeated_all_riders).save
    end

    if defeated_all_demon_lords_princes?(game)
      Scoreentry.first_or_create(user_id: game.user_id,
                                 variant: game.version,
                                 trophy:  :defeated_all_demon_lords_princes).save
    end

    if defeated_all_quest_leaders?(game)
      Scoreentry.first_or_create(user_id: game.user_id,
                                 variant: game.version,
                                 trophy:  :defeated_all_quest_leaders).save
    end

    if defeated_all_quest_nemeses?(game)
      Scoreentry.first_or_create(user_id: game.user_id,
                                 variant: game.version,
                                 trophy:  :defeated_all_quest_nemeses).save
    end
  end

  # DNetHack specific trophies
  dnethack = helper_get_variant_for 'dnethack'
  if dnethack == game.version then
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :one_key
                              ).save if game.got_one_key?
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :three_keys
                              ).save if game.got_three_keys?
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :nine_keys
                              ).save if game.got_nine_keys?
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :dn_king
                              ).save if dnethack_king? game.user_id
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :dn_prince
                              ).save if dnethack_prince? game.user_id
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :dn_tour
                              ).save if dnethack_tour? game.user_id
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :killed_asmodeus
                              ).save if game.dnethack_defeated_asmodeus?
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :killed_demogorgon
                              ).save if game.dnethack_defeated_demogorgon?
  end

  # NetHack Fourk specific trophies
  if nh4k == game.version then
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :entered_the_sokoban_zoo
                              ).save if game.entered_the_sokoban_zoo?
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :entered_minetown_temple
                              ).save if game.entered_minetown_temple?
    Scoreentry.first_or_create(user_id: game.user_id,
                               variant: game.version,
                               trophy: :reached_mines_end
                              ).save if game.reached_mines_end?
  end

  slashthem = helper_get_variant_for 'slashthem'
  slex = helper_get_variant_for "slash'em extended"
  if [slex, slashthem].include? game.version then
    achievements = game.achieve.hex if game.achieve
    if achievements and achievements > 0 then
      for i in 12..$slash_achievements.size-1 do
        if achievements & 2**i > 0 then
          entry = Scoreentry.first(user_id: game.user_id,
                                   variant: game.version,
                                   trophy: $slash_achievements[i][1])
          if not entry then
            Scoreentry.create(user_id: game.user_id,
                              variant: game.version,
                              value: "1",
                              endtime: game.endtime,
                              trophy: $slash_achievements[i][1]).save
          end
        end
      end
    end
    if slex == game.version then
      generic_achievements(game, (game.achieveX||'').split(','))
    end

  end

  ## Non-Ascension cross-variant trophies
  # Sightseeing tour: finish a game in all variants
  Individualtrophy.add(game.user_id, "Sightseeing Tour",
                       :sightseeing_tour, "sightseeing.png") if sightseeing_tour? game.user_id
  # Walk In The Park: finish a game in half of the variants
  Individualtrophy.add(game.user_id, "Walk In The Park",
                       :walk_in_the_park, "walk_in_the_park.png") if walk_in_the_park? game.user_id

  # Anti-Stoner: defeat Medusa in all variants
  Individualtrophy.add(game.user_id, "Anti-Stoner",
                       :anti_stoner, "anti-stoner.png") if anti_stoner? game.user_id
  # Hemi-Stoner: defeat Medusa in half of the variants
  Individualtrophy.add(game.user_id, "Hemi-Stoner",
                       :hemi_stoner, "hemi-stoner.png") if hemi_stoner? game.user_id

  # Globetrotter: get a trophy for each variant
  Individualtrophy.add(game.user_id, "Globetrotter",
                       :globetrotter, "globetrotter.png") if globetrotter? game.user_id
  # Backpacking tourist: get a trophy for half of the variants
  Individualtrophy.add(game.user_id, "Backpacking Tourist",
                       :backpacking_tourist, "backpacking_tourist.png") if backpacking_tourist? game.user_id

  return false if not local_normalize_death(game)

  return false if not update_clan_scores(game)
end

def generic_achievements(game, achievements)
  achievements.each {|achievement|
    if Trophy.first variant: game.version, trophy: achievement
      entry = Scoreentry.first(user_id: game.user_id,
                               variant: game.version,
                               trophy:  achievement)
      if not entry then
        Scoreentry.create(user_id: game.user_id,
                          variant: game.version,
                          value:   1,
                          endtime: game.endtime,
                          trophy:  achievement).save
      end
    end
  }
end

def local_normalize_death(game)
  normalized_death = NormalizedDeath.first_or_create(game_id: game.id)
  normalized_death.death = game.normalize_death
  normalized_death.user_id = game.user_id
  normalized_death.save
end

def ascended_combinations_user_sql
  "SELECT DISTINCT version, role, race, align0, gender0 from games where ascended = 't' and user_id = ?"
end
def ascended_combinations_sql
  "SELECT DISTINCT version, role, race, align0, gender0 from games where ascended = 't' and user_id in (SELECT id FROM users WHERE clan_name = ?)"
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
  clan_endtimes = repository.adapter.select "SELECT * FROM (SELECT (SELECT clan_name FROM users WHERE user_id = id) AS clan, endtime, endtime+86400 AS endtime_end FROM games WHERE ascended='t' AND user_id IS NOT NULL) games WHERE clan = ? ORDER BY endtime", clan

  max_ascensions = 0
  clan_endtimes.each do |e|
    ascensions = (repository.adapter.select "select count(1) from games where (select clan_name from users where user_id = id) = ? and ascended='t' and endtime >= ? and endtime <= ?", e.clan, e.endtime, e.endtime_end)[0]
    max_ascensions = ascensions if ascensions > max_ascensions
  end
  return max_ascensions
end

def update_clan_scores(game)
  return true if not game.user_id

  # Clan competition
  clan_name = (User.get game.user_id).clan_name
  if clan_name then
    most_ascended_combinations = (repository.adapter.select "SELECT count(1) from ("+ascended_combinations_sql+") a;", clan_name)[0]
    c = ClanScoreEntry.first_or_new(clan_name: clan_name,
                                    trophy: :most_ascended_combinations)
    c.value = most_ascended_combinations
    c.save

    most_unique_deaths = (repository.adapter.select "SELECT count(1) from ("+unique_deaths_sql+") a;", clan_name)[0]
    c = ClanScoreEntry.first_or_new(clan_name: clan_name,
                                    trophy: :most_unique_deaths)
    c.value = most_unique_deaths
    c.save

    c = ClanScoreEntry.first_or_new(clan_name: clan_name,
                                    trophy: :most_ascensions_in_a_24_hour_period)
    c.value = most_ascensions_in_a_24_hour_period clan_name
    c.save

    # This one is new for 2012.
    # We didn't have this clan trophy for the 2011 tournament.
    most_variant_trophy_combinations = (repository.adapter.select "SELECT count(1) from ("+variant_trophy_combinations_sql+") a;", clan_name)[0]
    c = ClanScoreEntry.first_or_new(clan_name: clan_name,
                                    trophy: :most_variant_trophy_combinations)
    c.value = most_variant_trophy_combinations
    c.save

    # new clan trophies for 2013
    # Most Medusa kills
    most_medusa_kills = Game.all(user_id: User.all(clan_name: clan_name)).sum(:killed_medusa)
    c = ClanScoreEntry.first_or_new(clan_name: clan_name,
                                    trophy: :most_medusa_kills)
    c.value = most_medusa_kills
    c.save

    # Most games with all conducts broken
    most_full_conducts_broken = (repository.adapter.select "SELECT count(1) FROM games WHERE nconducts = 0 and user_id in (SELECT id FROM users WHERE clan_name = ?) and version != 'NH-1.3d';", clan_name)[0]
    c = ClanScoreEntry.first_or_new(clan_name: clan_name,
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
    h = ClanScoreHistory.first(trophy: e.trophy, clan_name: e.clan_name, order: :created_at.desc)
    # only record when points or rank has changed
    if not h or h.points != e.points or h.rank != e.rank or h.value != e.value
      ClanScoreHistory.create(e.attributes)
    end
  }
end

def rank_clans
  rank_collection(ClanScoreEntry.all(trophy: :most_ascended_combinations, order: :value.desc))
  rank_collection(ClanScoreEntry.all(trophy: :most_unique_deaths, order: :value.desc))
  rank_collection(ClanScoreEntry.all(trophy: :most_ascensions_in_a_24_hour_period, order: :value.desc))
  rank_collection(ClanScoreEntry.all(trophy: :most_variant_trophy_combinations, order: :value.desc))
  rank_collection(ClanScoreEntry.all(trophy: :most_medusa_kills, order: :value.desc))
  rank_collection(ClanScoreEntry.all(trophy: :most_full_conducts_broken, order: :value.desc))
end

def score_clans
  clanscoreentries = ClanScoreEntry.all(order: [:trophy.asc, :rank.asc], :trophy.not => 'clan_winner')

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
        c.points = (c.value.to_f / best_value.to_f).round(2)
      end
    end
    c.save
    #puts "#{c.trophy} #{best_value} #{c.value} #{c.rank} #{c.points}"
  end

  # calculate clan points
  clan_scores = repository.adapter.select "select sum(points) as sum_points, clan_name from clan_score_entries where trophy in ('most_ascended_combinations','most_unique_deaths','most_ascensions_in_a_24_hour_period','most_variant_trophy_combinations','most_full_conducts_broken','most_medusa_kills') group by clan_name"
  clan_scores.each do |clan_score|
    c = ClanScoreEntry.first_or_new(clan_name: clan_score.clan_name,
                                    trophy: :clan_winner)
    c.value = (clan_score.sum_points*100).to_i
    # round to 2 significant figures after decimal point
    c.points = clan_score.sum_points.round(2)
    c.save
  end

  rank_collection(ClanScoreEntry.all(trophy: :clan_winner, order: :value.desc))
end

# Update competition trophies for an ascended game,
# Currently there are no competition trophies for games that are not
# ascended.
def update_competition_scores_ascended(game)
  return true if not game.user_id

  u = UserScore.new(game.user_id)

  # Clan competitions
  nconducts = u.most_conducts_ascension(game.version)[0]
  c = CompetitionScoreEntry.first_or_new(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :most_conducts_ascension)
  c.value = nconducts
  c.save

  points = u.highest_scoring_ascension(game.version)[0]
  c = CompetitionScoreEntry.first_or_new(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :highest_scoring_ascension)
  c.value = points
  c.save

  points = u.lowest_scoring_ascension(game.version)[0]
  c = CompetitionScoreEntry.first_or_new(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :lowest_scoring_ascension)
  c.value = points
  c.save

  realtime = u.fastest_ascension_realtime(game.version)
  c = CompetitionScoreEntry.first_or_new(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :fastest_ascension_realtime)
  c.value = realtime
  c.save

  gametime = u.fastest_ascension_gametime(game.version)
  c = CompetitionScoreEntry.first_or_new(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :fastest_ascension_gametime)
  c.value = gametime
  c.save

  ascensions = u.most_ascensions(game.version)
  c = CompetitionScoreEntry.first_or_new(user_id: game.user_id,
                                         variant: game.version,
                                         trophy: :most_ascensions)
  c.value = ascensions
  c.save

  longest_ascension_streak = u.longest_ascension_streak(game.version)
  if longest_ascension_streak > 0 then
    c = CompetitionScoreEntry.first_or_new(user_id: game.user_id,
                                           variant: game.version,
                                           trophy: :longest_ascension_streaks)
    c.value = longest_ascension_streak
    c.save
  end

  v = game.version
  rank_collection(CompetitionScoreEntry.all(variant: v, trophy: :most_conducts_ascension, order: :value.desc))
  rank_collection(CompetitionScoreEntry.all(variant: v, trophy: :highest_scoring_ascension, order: :value.desc))
  rank_collection(CompetitionScoreEntry.all(variant: v, trophy: :lowest_scoring_ascension, order: :value.asc))
  rank_collection(CompetitionScoreEntry.all(variant: v, trophy: :fastest_ascension_realtime, order: :value.asc))
  rank_collection(CompetitionScoreEntry.all(variant: v, trophy: :fastest_ascension_gametime, order: :value.asc))
  rank_collection(CompetitionScoreEntry.all(variant: v, trophy: :most_ascensions, order: :value.desc))
  rank_collection(CompetitionScoreEntry.all(variant: v, trophy: :longest_ascension_streaks, order: :value.desc))

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
  Scoreentry.count(user_id: game.user_id,
                   variant: game.version,
                   trophy: riders) == riders.count
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
  Scoreentry.count(user_id: game.user_id,
                   variant: game.version,
                   trophy: demons) == demons.count

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
  Scoreentry.count(user_id: game.user_id,
                   variant: game.version,
                   trophy: leaders) == leaders.count
end

def defeated_all_quest_nemeses?(game)
  nemeses = [
    :defeated_minion_of_huhetotl,
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
  if game.version == unnethack
    nemeses << :defeated_warden_arianna
  end
  Scoreentry.count(user_id: game.user_id,
                   variant: game.version,
                   trophy: nemeses) == nemeses.count
end

# All conducts: follow each conduct in at least one ascension.
def all_conducts?(user_id, variant)
  conducts = repository.adapter.select "select conduct from games where version = ? and user_id = ? and ascended='t';", variant, user_id

  # bit-or all conduct integers to find out if all 12 conducts have been followed overall
  aggregated_conducts = 0
  conducts.each { |c| aggregated_conducts |= (Integer c) }

  aggregated_conducts &= 2**12-1; # limit to vanilla conducts

  return aggregated_conducts == 2**12-1 # Vegetarian, Vegan, Foodless, Atheist, Weaponless, Pacifist, Literate, Polypiles, Polyself, Wishing, Wishing for Artifacts, Genocide
end
def all_conducts_streak?(user_id, variant)
  all_stuff_streak "nconducts", 12, user_id, variant
end

# All roles: ascend a character for each role.
def all_roles?(user_id, variant)
  anz = repository.adapter.select "select count(distinct role) from games where version = ? and user_id = ? and ascended='t';", variant, user_id
  return anz[0] >= 13 # Archeologist, Barbarian, Caveman, Healer, Knight, Monk, Priest, Ranger, Rogue, Samurai, Tourist, Valkyrie, Wizard
end
def all_roles_streak?(user_id, variant)
  all_stuff_streak "role", 13, user_id, variant
end

# All races: ascend a character of every race.
def all_races?(user_id, variant)
  anz = repository.adapter.select "select count(distinct race) from games where version = ? and user_id = ? and ascended='t';", variant, user_id
  return anz[0] == 5 # Dwarves, Elves, Gnomes, Humans, Orcs
end
def all_races_streak?(user_id, variant)
  all_stuff_streak "race", 5, user_id, variant
end

# All alignments: ascend a character of every alignment (the starting alignment is considered). 
def all_alignments?(user_id, variant)
  anz = repository.adapter.select "select count(distinct align0) from games where version = ? and user_id = ? and ascended='t';", variant, user_id
  return anz[0] == 3 # Lawful, Neutral, Chaotic
end
def all_alignments_streak?(user_id, variant)
  all_stuff_streak "align0", 3, user_id, variant
end

# All genders: ascend a character of each gender (the starting gender is considered).
def all_genders?(user_id, variant)
  anz = repository.adapter.select "select count(distinct gender0) from games where version = ? and user_id = ? and ascended='t';", variant, user_id
  return anz[0] == 2 # Mal, Fem
end
def all_genders_streak?(user_id, variant)
  all_stuff_streak "gender0", 2, user_id, variant
end

def all_stuff_streak(column, len, user_id, variant)
  games = (repository.adapter.select "select * from (select "+column+" as column,ascended,endtime from games where version = ? and user_id = ? union all select "+column+" as column,ascended,endtime from start_scummed_games where version = ? and user_id = ?) order by endtime desc;", variant, user_id, variant, user_id)

  distinct_values = {}
  games.each {|game|
    if game.ascended == 't'
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

  Scoreentry.first_or_create(user_id: game.user_id,
                             variant: game.version,
                             trophy: :all_conducts).save if all_conducts? game.user_id, game.version
  Scoreentry.first_or_create(user_id: game.user_id,
                             variant: game.version,
                             trophy: :all_roles).save if all_roles? game.user_id, game.version
  Scoreentry.first_or_create(user_id: game.user_id,
                             variant: game.version,
                             trophy: :all_races).save if all_races? game.user_id, game.version
  Scoreentry.first_or_create(user_id: game.user_id,
                             variant: game.version,
                             trophy: :all_alignments).save if all_alignments? game.user_id, game.version
  Scoreentry.first_or_create(user_id: game.user_id,
                             variant: game.version,
                             trophy: :all_genders).save if all_genders? game.user_id, game.version
end
