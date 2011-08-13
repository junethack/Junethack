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

# Helper class for calculating ascension density
class AccountCalc
    attr_accessor :games, :score, :account, :game1, :game2
    def initialize
        @games = [ ]
        @score = 0
    end

    def num_ascensions
        ascensions = 0
        @games.each do |game|
            ascensions += 1 if game.death == 'ascended'
        end
        ascensions
    end

    def calculate_score_between(games, min_score = 0.0)
        final_max = 0.0
        max_so_far = max_ending_here = 0.0
        for asc in games do
            a = asc.death == 'ascended' ? 1.0 : -1.0
            max_ending_here = max_ending_here + a if max_ending_here + a > 0
            max_so_far = max_so_far > max_ending_here ? max_so_far : max_ending_here
        end
        final_max = final_max > max_so_far ? final_max : max_so_far
        final_max
    end

    def calculate_score
        # Calculate the longest distance between ascensions
        # So first ascension and last ascension

        @score = calculate_score_between(@games)
        @score
    end
end


def best_sustained_ascension_rate(and_collection=nil)
    # First step, collect the games.
    accounts = Account.all
    accounts_c = { }
    accounts.each do |account|
        accounts_c[account.name] = AccountCalc.new
        accounts_c[account.name].account = account
        accounts_c[account.name].games = Game.all(:name => account.name,
                                                  :order => [:endtime.desc])
    end

    # Sort the games and calculate score
    accounts_c.each do |account, account_class|
        account_class.calculate_score
    end

    users = { }
    # Wrap the thing up to users.
    accounts_c.each do |account, account_class|
        users[account_class.account.user.login] = { } if
            users[account_class.account.user.login].nil?
        u = users[account_class.account.user.login]
        if u[:score].nil? or u[:score] < account_class.score then
            u[:score] = account_class.score
            u[:game1] = account_class.game1
            u[:game2] = account_class.game2
        end
    end

    users.sort_by{|username, info| -info[:score]}
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

## Cross-variant trophies
# King of the world: ascend in all variants
def king_of_the_world?(user)
    anz = repository.adapter.select "select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and ascended='t';", user
    return anz[0] == 4
end

# Sightseeing tour: finish a game in all variants (die after at least 1000 turns or ascend)
def sightseeing_tour?(user)
    anz = repository.adapter.select "select count(distinct version) from games where user_id = ? and version != 'NH-1.3d' and turns >= 1000;", user
    return anz[0] == 4
end
#  Globetrotter: get a trophy for each variant
def globetrotter?(user)
    anz = repository.adapter.select "select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d';", user
    return anz[0] == 4
end
#  Anti-Stoner: defeat Medusa in each variant
def anti_stoner?(user)
    anz = repository.adapter.select "select count(distinct variant) from scoreentries where user_id = ? and variant != 'NH-1.3d' and trophy='defeated_medusa';", user
    return anz[0] == 4
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

            ## Non-Ascension Individual trophies
            # King of the world: ascend in all variants
            Individualtrophy.first_or_create(:user_id => game.user_id,
                :trophy => :king_of_the_world,
                :icon => "king.png").save if king_of_the_world? game.user_id

            return false if not update_competition_scores_ascended(game)

            return false if not update_all_stuff(game)
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
        end

        # AceHack
        if game.version == '3.6.0' then
            ## AceHack specific trophies as it doesn't track xlogfile achievements
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
                :trophy => :did_invocation,
                :icon => "m-invocation.png").save if game.event_did_invocation?
            # defeated a high priest
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :defeated_a_high_priest,
                :icon => "m-amulet.png").save if game.event_defeated_a_high_priest?
            # entered the planes
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :entered_planes,
                :icon => "m-planes.png").save if game.entered_planes?
            # entered astral
            Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
                :trophy => :entered_astral,
                :icon => "m-astral.png").save if game.entered_astral?
        end

    ## Non-Ascension cross-variant trophies
    # Sightseeing tour: finish a game in all variants
    Individualtrophy.first_or_create(:user_id => game.user_id,
        :trophy => :sightseeing_tour,
        :icon => "sightseeing.png").save if sightseeing_tour? game.user_id
    # Anti-Stoner: defeat Medusa in all variants
    Individualtrophy.first_or_create(:user_id => game.user_id,
        :trophy => :anti_stoner,
        :icon => "anti-stoner.png").save if anti_stoner? game.user_id
    # Globetrotter: get a trophy for each variant
    Individualtrophy.first_or_create(:user_id => game.user_id,
        :trophy => :globetrotter,
        :icon => "globetrotter.png").save if globetrotter? game.user_id

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
    "SELECT DISTINCT variant, trophy from scoreentries where user_id in (SELECT id FROM users WHERE clan = ?)"
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
        points = (repository.adapter.select "SELECT SUM(points) FROM games WHERE user_id in (SELECT id FROM users WHERE clan = ?);", clan_name)[0]
        c = ClanScoreEntry.first_or_new(:clan_name => clan_name,
                                        :trophy  => "most_points",
                                        :icon => "clan-points.png")
        c.value = points
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

        # we don't have this clan trophy for the 2011 tournament
        #most_variant_trophy_combinations = (repository.adapter.select "SELECT count(1) from ("+variant_trophy_combinations_sql+");", clan_name)[0]
        #c = ClanScoreEntry.first_or_new(:clan_name => clan_name,
        #                                :trophy  => "most_variant_trophy_combinations",
        #                                :icon => "clan-variant-trophies.png")
        #c.value = most_variant_trophy_combinations
        #c.save
    end

    rank_collection(ClanScoreEntry.all(:trophy  => "most_points", :order => [ :value.desc ]))
    rank_collection(ClanScoreEntry.all(:trophy  => "most_ascended_combinations", :order => [ :value.desc ]))
    rank_collection(ClanScoreEntry.all(:trophy  => "most_unique_deaths", :order => [ :value.desc ]))
    rank_collection(ClanScoreEntry.all(:trophy  => "most_ascensions_in_a_24_hour_period", :order => [ :value.desc ]))
    #rank_collection(ClanScoreEntry.all(:trophy  => "most_variant_trophy_combinations", :order => [ :value.desc ]))
    score_clans

    return true
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
              c.points = (c.value.to_f*100 / best_value.to_f).round.to_f / 100
            end
        end
        c.save
        #puts "#{c.trophy} #{best_value} #{c.value} #{c.rank} #{c.points}"
    end

    # calculate clan points
    clan_scores = repository.adapter.select "select sum(points) as sum_points, clan_name from clan_score_entries where trophy in ('most_ascended_combinations','most_points','most_unique_deaths','most_ascensions_in_a_24_hour_period') group by clan_name"
    clan_scores.each do |clan_score|
        c = ClanScoreEntry.first_or_new(:clan_name => clan_score.clan_name,
                                        :trophy  => "clan_winner")
        c.value = (clan_score.sum_points*100).to_i
        c.points = clan_score.sum_points
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
    anz = repository.adapter.select "select max(nconducts) from games where version = ? and user_id = ? and ascended='t';", variant, user_id
    return anz[0] == 12 # Vegetarian, Vegan, Foodless, Atheist, Weaponless, Pacifist, Literate, Polypiles, Polyself, Wishing, Wishing for Artifacts, Genocide
end

# All roles: ascend a character for each role.
def all_roles?(user_id, variant)
    anz = repository.adapter.select "select count(distinct role) from games where version = ? and user_id = ? and ascended='t';", variant, user_id
    return anz[0] == 13 # Archeologist, Barbarian, Caveman, Healer, Knight, Monk, Priest, Ranger, Rogue, Samurai, Tourist, Valkyrie, Wizard
end

# All races: ascend a character of every race.
def all_races?(user_id, variant)
    anz = repository.adapter.select "select count(distinct race) from games where version = ? and user_id = ? and ascended='t';", variant, user_id
    return anz[0] == 5 # Dwarves, Elves, Gnomes, Humans, Orcs
end

# All alignments: ascend a character of every alignment (the starting alignment is considered). 
def all_alignments?(user_id, variant)
    anz = repository.adapter.select "select count(distinct align0) from games where version = ? and user_id = ? and ascended='t';", variant, user_id
    return anz[0] == 3 # Lawful, Neutral, Chaotic
end

# All genders: ascend a character of each gender (the starting gender is considered).
def all_genders?(user_id, variant)
    anz = repository.adapter.select "select count(distinct gender0) from games where version = ? and user_id = ? and ascended='t';", variant, user_id
    return anz[0] == 2 # Mal, Fem
end

def update_all_stuff(game)
    return true if not game.user_id and not game.ascended

    Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
       :trophy => :all_conducts).save if all_conducts? game.user_id, game.version
    #Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
    #   :trophy => :all_conducts_streak).save if all_? game.user_id, game.version
    Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
       :trophy => :all_roles).save if all_roles? game.user_id, game.version
    #Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
    #   :trophy => :all_roles_streak).save if all_? game.user_id, game.version
    Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
       :trophy => :all_races).save if all_races? game.user_id, game.version
    #Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
    #   :trophy => :all_races_streak).save if all_? game.user_id, game.version
    Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
       :trophy => :all_alignments).save if all_alignments? game.user_id, game.version
    #Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
    #   :trophy => :all_alignments_streak).save if all_? game.user_id, game.version
    Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
       :trophy => :all_genders).save if all_genders? game.user_id, game.version
    #Scoreentry.first_or_create(:user_id => game.user_id, :variant => game.version,
    #   :trophy => :all_genders_streak).save if all_? game.user_id, game.version
end
