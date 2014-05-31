require 'userscore'
require 'trophyscore'
require 'normalize_death'

# This one returns last games ordered by endtime, with the latest game
# first.
# Optionally give conditions and limit.
def get_last_games(condition={}, limit=10)
    Game.all( {:order => [ :endtime.desc ], :limit => limit}.merge condition )
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
    score.sort_by{|user, score| -score}
end

## Cross Variant Achievements
# King of the world: ascend in all variants
def king_of_the_world?(user)
    anz = repository.adapter.select "select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and ascended='t';", user
    return anz[0] == $variants.size
end

def prince_of_the_world?(user)
    anz = repository.adapter.select "select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and ascended='t';", user
    return anz[0] >= ($variants.size/2)
end

# Sightseeing tour: finish a game in all variants (die after at least 1000 turns or ascend)
def sightseeing_tour?(user)
    anz = repository.adapter.select "select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and turns >= 1000;", user
    return anz[0] == $variants.size
end
# Walk In The Park: finish a game in half of the variants
def walk_in_the_park?(user)
    anz = repository.adapter.select "select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and turns >= 1000;", user
    return anz[0] >= ($variants.size/2)
end


#  Globetrotter: get a trophy for each variant
def globetrotter?(user)
    anz = repository.adapter.select "select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d';", user
    return anz[0] == $variants.size
end
# Backpacking tourist: get a trophy for half of the variants
def backpacking_tourist?(user)
    anz = repository.adapter.select "select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d';", user
    return anz[0] >= ($variants.size/2)
end

# Anti-Stoner: defeat Medusa in each variant
def anti_stoner?(user)
    anz = repository.adapter.select "select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d' and trophy='defeated_medusa';", user
    return anz[0] == $variants.size
end
# Hemi-Stoner: defeat Medusa in half of the variants
def hemi_stoner?(user)
    anz = repository.adapter.select "select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d' and trophy='defeated_medusa';", user
    return anz[0] >= ($variants.size/2)
end


def update_scores(game)
    return true if not game.user_id

    t = TrophyScore.new
    if game.version != 'NH-1.3d' then
        if game.ascended
            # ascended
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :ascended,
                :icon => "ascension.png").save

            Scoreentry.all(:variant => game.version,
                           :trophy  => "most_ascensions").destroy
            t.most_ascensions(game.version).each do |e|
                Scoreentry.create(:user_id => e.user_id,
                                  :variant => game.version,
                                  :value   => e.ascension.to_s,
                                  :endtime => e.endtime,
                                  :trophy  => "most_ascensions",
                                  :icon    => "c-most-ascensions.png").save
            end

            Scoreentry.all(:variant => game.version,
                           :trophy  => "highest_scoring_ascension").destroy
            t.highest_scoring_ascension(game.version).each do |e|
                Scoreentry.create(:user_id => e.user_id,
                                  :variant => game.version,
                                  :value   => e.points.to_s,
                                  :endtime => e.endtime,
                                  :trophy  => "highest_scoring_ascension",
                                  :icon    => "c-highest-score.png").save
            end

            Scoreentry.all(:variant => game.version,
                           :trophy  => "lowest_scoring_ascension").destroy
            t.lowest_scoring_ascension(game.version).each do |e|
                Scoreentry.create(:user_id => e.user_id,
                                  :variant => game.version,
                                  :value   => e.points.to_s,
                                  :endtime => e.endtime,
                                  :trophy  => "lowest_scoring_ascension",
                                  :icon    => "c-lowest-score.png").save
            end

            Scoreentry.all(:variant => game.version,
                           :trophy  => "fastest_ascension_realtime").destroy
            t.fastest_ascension_realtime(game.version).each do |e|
                Scoreentry.create(:user_id => e.user_id,
                                  :variant => game.version,
                                  :value   => e.duration.to_s,
                                  :value_display => parse_seconds(e.duration),
                                  :endtime => e.endtime,
                                  :trophy  => "fastest_ascension_realtime",
                                  :icon    => "c-fastest-realtime.png").save
            end

            Scoreentry.all(:variant => game.version,
                           :trophy  => "fastest_ascension_gametime").destroy
            t.fastest_ascension_gametime(game.version).each do |e|
                Scoreentry.create(:user_id => e.user_id,
                                  :variant => game.version,
                                  :value   => e.duration.to_s,
                                  :endtime => e.endtime,
                                  :trophy  => "fastest_ascension_gametime",
                                  :icon    => "c-fastest-gametime.png").save
            end

            Scoreentry.all(:variant => game.version,
                           :trophy  => "longest_ascension_streaks").destroy
            t.longest_ascension_streaks(game.version).each do |e|
                Scoreentry.create(:user_id => e.user_id,
                                  :variant => game.version,
                                  :value   => e.streaks.to_s,
                                  :endtime => e.endtime,
                                  :trophy  => "longest_ascension_streaks",
                                  :icon    => "c-longest-streak.png").save
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
                    entry = Scoreentry.first(:user_id => game.user_id,
                                             :variant => game.version,
                                             :trophy => $achievements[i][0],
                                             :icon => $achievements[i][2])
                    if not entry then
                        Scoreentry.create(:user_id => game.user_id,
                                          :variant => game.version,
                                          :value   => "1",
                                          :endtime => game.endtime,
                                          :trophy  => $achievements[i][0],
                                          :icon    => $achievements[i][2]).save
                    end
                end
            end
        end
        ## Non-Ascension non-devnull achievement
        # escaped in celestial disgrace
        Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
            :trophy => :escapologist,
            :icon => "escapologist.png").save if game.escapologist?
    end

        if game.version == 'NH-1.3d' then
            ## NetHack 1.3d specific trophies
            # escaped (with the amulet)
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :ascended_old,
                :icon => "old-ascension.png").save if game.event_ascended?
            # got crowned
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :crowned,
                :icon => "old-crowned.png").save if game.got_crowned?
            # entered hell
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :entered_hell,
                :icon => "old-hell.png").save if game.entered_hell?
            # defeated rodney
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :defeated_old_rodney,
                :icon => "old-wizard.png").save if game.defeated_rodney?
        else
            ## AceHack and UnNetHack-specific trophies
            # Too good for quests
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :ascended_without_defeating_nemesis,
                :icon => "m-no-nemesis.png").save if game.ascended_without_defeating_nemesis?
            # Too good for Vladbanes
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :ascended_without_defeating_vlad,
                :icon => "m-no-vlad.png").save if game.ascended_without_defeating_vlad?
            # Too good for... wait, what? How?
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :ascended_without_defeating_rodney,
                :icon => "m-no-wizard.png").save if game.ascended_without_defeating_rodney?
            # Too good for a brain
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :ascended_without_defeating_cthulhu,
                :icon => "m-no-cthulhu.png").save if game.ascended_without_defeating_cthulhu?
            # Hoarder
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :ascended_with_all_invocation_items,
                :icon => "m-hoarder.png").save if game.ascended_with_all_invocation_items?
            # Assault on Fort Knox
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :defeated_croesus,
                :icon => "m-croesus.png").save if game.defeated_croesus?
            # No membership card
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :defeated_one_eyed_sam,
                :icon => "m-sam.png").save if game.defeated_one_eyed_sam?
            # Heaven or Hell
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :heaven_or_hell,
                :icon => "heaven-or-hell.png").save if game.ascended_heaven_or_hell?
            # Mini-Croesus
            Scoreentry.first_or_create(:user_id => game.user_id,
                :variant => game.version,
                :trophy => :mini_croesus,
                :icon => "m-mini-croesus.png").save if game.mini_croesus?
        end

        # AceHack and NetHack4 specific trophies
        acehack = helper_get_variant_for 'acehack'
        nethack4 = helper_get_variant_for 'nethack4'
        if [acehack, nethack4].include? game.version then
            ## specific trophies as they don't track xlogfile achievements
            # bought an Oracle consultation
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :bought_oracle_consultation,
                :icon => "m-soko.png").save if game.event_bought_oracle_consultation?
            # reached the quest portal level
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :accepted_for_quest,
                :icon => "m-luckstone.png").save if game.event_accepted_for_quest?
            # defeated the quest nemesis
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :defeated_quest_nemesis,
                :icon => "m-bell.png").save if game.event_defeated_quest_nemesis?
            # defeated Medusa
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :defeated_medusa,
                :icon => "m-medusa.png").save if game.event_defeated_medusa?
            # entered Gehennom the front way
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :event_entered_gehennom_front_way,
                :icon => "m-gehennom.png").save if game.event_entered_gehennom_front_way?
            # defeated Vlad
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :defeated_vlad,
                :icon => "m-candelabrum.png").save if game.event_defeated_vlad?
            # defeated Rodney at least once
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :defeated_rodney,
                :icon => "m-book.png").save if game.event_defeated_rodney?
            # did the invocation
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :performed_the_invocation_ritual,
                :icon => "m-invocation.png").save if game.event_did_invocation?
            # defeated a high priest
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :defeated_a_high_priest,
                :icon => "m-amulet.png").save if game.event_defeated_a_high_priest?
            # entered the planes
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :entered_elemental_planes,
                :icon => "m-planes.png").save if game.entered_planes?
            # entered astral
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :entered_astral_plane,
                :icon => "m-astral.png").save if game.entered_astral?
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

    return false if not update_clan_scores(game)

    return false if not local_normalize_death(game)
end

def local_normalize_death(game)
    normalized_death = NormalizedDeath.first_or_create(:game_id => game.id)
    normalized_death.death = game.normalize_death
    normalized_death.user_id = game.user_id
    normalized_death.save
end

def ascended_combinations_user_sql
    "SELECT DISTINCT version, role, race, align0, gender0 from games where ascended = 't' and user_id = ?"
end
def ascended_combinations_sql
    "SELECT DISTINCT version, role, race, align0, gender0 from games where ascended = 't' and user_id in (SELECT id FROM users WHERE clan = ?)"
end
def unique_deaths_sql
    "SELECT DISTINCT death from normalized_deaths where user_id in (SELECT id FROM users WHERE clan = ?)"
end

def variant_trophy_combinations_sql
    "SELECT DISTINCT variant, trophy from (SELECT user_id, variant, trophy from scoreentries UNION SELECT user_id, variant, trophy from competition_score_entries) where user_id in (SELECT id FROM users WHERE clan = ?)"
end
def variant_trophy_combinations_user_sql
    "SELECT DISTINCT variant, trophy from (SELECT user_id, variant, trophy from scoreentries UNION SELECT user_id, variant, trophy from competition_score_entries) where user_id = ?"
end

def most_ascensions_in_a_24_hour_period(clan)
    clan_endtimes = repository.adapter.select "select * from (select (select clan from users where user_id = id) as clan, endtime, endtime+86400 as endtime_end from games where ascended='t' and clan = ? and user_id is not null order by endtime)", clan

    max_ascensions = 0
    clan_endtimes.each do |e|
        ascensions = (repository.adapter.select "select count(1) from games where (select clan from users where user_id = id) = ? and ascended='t' and endtime >= ? and endtime <= ?", e.clan, e.endtime, e.endtime_end)[0]
        max_ascensions = ascensions if ascensions > max_ascensions
    end
    return max_ascensions
end

def update_clan_scores(game)
    return true if not game.user_id

    # Clan competition
    clan_name = (User.get game.user_id).clan
    if clan_name then
        log_points = (repository.adapter.select "SELECT SUM(length(points)-1) FROM games WHERE user_id in (SELECT id FROM users WHERE clan = ?);", clan_name)[0]
        c = ClanScoreEntry.first_or_new(:clan_name => clan_name,
                                        :trophy  => "most_log_points",
                                        :icon => "clan-points.png")
        c.value = log_points
        c.save

        most_ascended_combinations = (repository.adapter.select "SELECT count(1) from ("+ascended_combinations_sql+");", clan_name)[0]
        c = ClanScoreEntry.first_or_new(:clan_name => clan_name,
                                        :trophy  => "most_ascended_combinations",
                                        :icon => "clan-combinations.png")
        c.value = most_ascended_combinations
        c.save

        most_unique_deaths = (repository.adapter.select "SELECT count(1) from ("+unique_deaths_sql+");", clan_name)[0]
        c = ClanScoreEntry.first_or_new(:clan_name => clan_name,
                                        :trophy  => "most_unique_deaths",
                                        :icon => "clan-deaths.png")
        c.value = most_unique_deaths
        c.save

        c = ClanScoreEntry.first_or_new(:clan_name => clan_name,
                                        :trophy  => "most_ascensions_in_a_24_hour_period",
                                        :icon => "clan-24h.png")
        c.value = most_ascensions_in_a_24_hour_period clan_name
        c.save

        # This one is new for 2012.
        # We didn't have this clan trophy for the 2011 tournament.
        most_variant_trophy_combinations = (repository.adapter.select "SELECT count(1) from ("+variant_trophy_combinations_sql+");", clan_name)[0]
        c = ClanScoreEntry.first_or_new(:clan_name => clan_name,
                                        :trophy  => "most_variant_trophy_combinations",
                                        :icon => "clan-variant-trophies.png")
        c.value = most_variant_trophy_combinations
        c.save

        # new clan trophies for 2013
        # Most Medusa kills
        clanGames = Game.all(:user_id => User.all(:clan => clan_name))
        most_medusa_kills = 0
        clanGames.each {|game| most_medusa_kills +=1 if game.defeated_medusa? }
        c = ClanScoreEntry.first_or_new(:clan_name => clan_name,
                                        :trophy  => "most_medusa_kills",
                                        :icon => "clan-medusa-kills.png")
        c.value = most_medusa_kills
        c.save

        # Most games with all conducts broken
        most_full_conducts_broken = (repository.adapter.select "SELECT count(1) FROM games WHERE nconducts = 0 and user_id in (SELECT id FROM users WHERE clan = ?);", clan_name)[0]
        c = ClanScoreEntry.first_or_new(:clan_name => clan_name,
                                        :trophy  => "most_full_conducts_broken",
                                        :icon => "clan-full-conducts-broken.png")
        c.value = most_full_conducts_broken
        c.save

    end

    rank_clans
    score_clans

    return true
end

def rank_clans
    rank_collection(ClanScoreEntry.all(:trophy  => "most_log_points", :order => [ :value.desc ]))
    rank_collection(ClanScoreEntry.all(:trophy  => "most_ascended_combinations", :order => [ :value.desc ]))
    rank_collection(ClanScoreEntry.all(:trophy  => "most_unique_deaths", :order => [ :value.desc ]))
    rank_collection(ClanScoreEntry.all(:trophy  => "most_ascensions_in_a_24_hour_period", :order => [ :value.desc ]))
    rank_collection(ClanScoreEntry.all(:trophy  => "most_variant_trophy_combinations", :order => [ :value.desc ]))
    rank_collection(ClanScoreEntry.all(:trophy  => "most_medusa_kills", :order => [ :value.desc ]))
    rank_collection(ClanScoreEntry.all(:trophy  => "most_full_conducts_broken", :order => [ :value.desc ]))
end

def score_clans
    clanscoreentries = ClanScoreEntry.all(:order => [:trophy.asc, :rank.asc], :trophy.not => 'clan_winner')

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
    clan_scores = repository.adapter.select "select sum(points) as sum_points, clan_name from clan_score_entries where trophy in ('most_ascended_combinations','most_log_points','most_unique_deaths','most_ascensions_in_a_24_hour_period','most_variant_trophy_combinations','most_full_conducts_broken','most_medusa_kills') group by clan_name"
    clan_scores.each do |clan_score|
        c = ClanScoreEntry.first_or_new(:clan_name => clan_score.clan_name,
                                        :trophy  => "clan_winner")
        c.value = (clan_score.sum_points*100).to_i
        # round to 2 significant figures after decimal point
        c.points = clan_score.sum_points.round(2)
        c.save
    end

    rank_collection(ClanScoreEntry.all(:trophy  => "clan_winner", :order => [ :value.desc ]))
end

# Update competition trophies for an ascended game,
# Currently there are no competition trophies for games that are not
# ascended.
def update_competition_scores_ascended(game)
    return true if not game.user_id

    u = UserScore.new(game.user_id)

    # Clan competitions
    nconducts = u.most_conducts_ascension(game.version)[0]
    c = CompetitionScoreEntry.first_or_new(:user_id => game.user_id,
                                        :variant => game.version,
                                        :trophy  => "most_conducts_ascension",
                                        :icon => "c-most-conducts.png")
    c.value = nconducts
    c.save

    points = u.highest_scoring_ascension(game.version)[0]
    c = CompetitionScoreEntry.first_or_new(:user_id => game.user_id,
                                        :variant => game.version,
                                        :trophy  => "highest_scoring_ascension",
                                        :icon => "c-highest-score.png")
    c.value = points
    c.save

    points = u.lowest_scoring_ascension(game.version)[0]
    c = CompetitionScoreEntry.first_or_new(:user_id => game.user_id,
                                        :variant => game.version,
                                        :trophy  => "lowest_scoring_ascension",
                                        :icon => "c-lowest-score.png")
    c.value = points
    c.save

    realtime = u.fastest_ascension_realtime(game.version)
    c = CompetitionScoreEntry.first_or_new(:user_id => game.user_id,
                                        :variant => game.version,
                                        :trophy  => "fastest_ascension_realtime",
                                        :icon => "c-fastest-realtime.png")
    c.value = realtime
    c.save

    gametime = u.fastest_ascension_gametime(game.version)
    c = CompetitionScoreEntry.first_or_new(:user_id => game.user_id,
                                        :variant => game.version,
                                        :trophy  => "fastest_ascension_gametime",
                                        :icon => "c-fastest-gametime.png")
    c.value = gametime
    c.save

    ascensions = u.most_ascensions(game.version)
    c = CompetitionScoreEntry.first_or_new(:user_id => game.user_id,
                                        :variant => game.version,
                                        :trophy  => "most_ascensions",
                                        :icon => "c-most-ascensions.png")
    c.value = ascensions
    c.save

    longest_ascension_streak = u.longest_ascension_streak(game.version)
    if longest_ascension_streak > 0 then
        c = CompetitionScoreEntry.first_or_new(:user_id => game.user_id,
                                            :variant => game.version,
                                            :trophy  => "longest_ascension_streaks",
                                            :icon => "c-longest-streak.png")
        c.value = longest_ascension_streak
        c.save
    end

    v = game.version
    rank_collection(CompetitionScoreEntry.all(:variant => v, :trophy  => "most_conducts_ascension", :order => [ :value.desc ]))
    rank_collection(CompetitionScoreEntry.all(:variant => v, :trophy  => "highest_scoring_ascension", :order => [ :value.desc ]))
    rank_collection(CompetitionScoreEntry.all(:variant => v, :trophy  => "lowest_scoring_ascension", :order => [ :value.asc ]))
    rank_collection(CompetitionScoreEntry.all(:variant => v, :trophy  => "fastest_ascension_realtime", :order => [ :value.asc ]))
    rank_collection(CompetitionScoreEntry.all(:variant => v, :trophy  => "fastest_ascension_gametime", :order => [ :value.asc ]))
    rank_collection(CompetitionScoreEntry.all(:variant => v, :trophy  => "most_ascensions", :order => [ :value.desc ]))
    rank_collection(CompetitionScoreEntry.all(:variant => v, :trophy  => "longest_ascension_streaks", :order => [ :value.desc ]))

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


# All conducts: follow each conduct in at least one ascension.
def all_conducts?(user_id, variant)
    conducts = repository.adapter.select "select conduct from games where version = ? and user_id = ? and ascended='t';", variant, user_id

    # bit-or all conduct integers to find out if all 12 conducts have been followed overall
    aggregated_conducts = 0
    conducts.each { |c| aggregated_conducts |= (Integer c) }

    return aggregated_conducts == 2**12-1 # Vegetarian, Vegan, Foodless, Atheist, Weaponless, Pacifist, Literate, Polypiles, Polyself, Wishing, Wishing for Artifacts, Genocide
end
def all_conducts_streak?(user_id, variant)
    all_stuff_streak "nconducts", 12, user_id, variant
end

# All roles: ascend a character for each role.
def all_roles?(user_id, variant)
    anz = repository.adapter.select "select count(distinct role) from games where version = ? and user_id = ? and ascended='t';", variant, user_id
    return anz[0] == 13 # Archeologist, Barbarian, Caveman, Healer, Knight, Monk, Priest, Ranger, Rogue, Samurai, Tourist, Valkyrie, Wizard
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
    asc = 0;
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

    Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
       :trophy => :all_conducts).save if all_conducts? game.user_id, game.version
    #Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
    #   :trophy => :all_conducts_streak).save if all_conducts_streak? game.user_id, game.version
    Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
       :trophy => :all_roles).save if all_roles? game.user_id, game.version
    #Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
    #   :trophy => :all_roles_streak).save if all_roles_streak? game.user_id, game.version
    Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
       :trophy => :all_races).save if all_races? game.user_id, game.version
    #Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
    #   :trophy => :all_races_streak).save if all_races_streak? game.user_id, game.version
    Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
       :trophy => :all_alignments).save if all_alignments? game.user_id, game.version
    #Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
    #   :trophy => :all_alignments_streak).save if all_alignments_streak? game.user_id, game.version
    Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
       :trophy => :all_genders).save if all_genders? game.user_id, game.version
    #Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
    #   :trophy => :all_genders_streak).save if all_genders_streak? game.user_id, game.version
end
