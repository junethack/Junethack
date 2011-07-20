require 'userscore'
require 'trophyscore'

# Limits by 10 any collection
def limit_by_10(collection)
    return collection.take(10) if collection.instance_of?(Array)
    collection.all(:limit => 10)
end

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

## Individual trophies
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
                           :trophy  => "most_conducts_ascension").destroy
            t.most_conducts_ascension(game.version).each do |e|
                Scoreentry.create(:user_id => e.user_id,
                                  :variant => game.version,
                                  :value   => e.nconducts.to_s,
                                  :endtime => e.endtime,
                                  :trophy  => "most_conducts_ascension",
                                  :icon    => "c-most-conducts.png").save
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

    ## Non-Ascension Individual trophies
    # Sightseeing tour: finish a game in all variants
    Individualtrophy.first_or_create(:user_id => game.user_id,
        :trophy => :sightseeing_tour,
        :icon => "sightseeing.png").save if sightseeing_tour? game.user_id
    # Globetrotter: get a trophy for each variant
    Individualtrophy.first_or_create(:user_id => game.user_id,
        :trophy => :globetrotter,
        :icon => "globetrotter.png").save if globetrotter? game.user_id

    return update_clan_scores(game)
end

def update_clan_scores(game)
    return true if not game.user_id

    # Clan competition
    clan_name = (User.get game.user_id).accounts.collect{|a| a.clan_name}.compact[0]
    if clan_name then
        points = (repository.adapter.select "SELECT SUM(points) FROM games WHERE user_id in (SELECT user_id FROM accounts WHERE clan_name IN (SELECT name FROM clans WHERE name = ?));", clan_name)[0]
        c = ClanScoreEntry.first_or_new(:clan_name => clan_name,
                                        :trophy  => "most_points",
                                        :icon => "clan-points.png")
        if c.value.nil? or c.value < points then
            c.value = points
            c.save
        end
    end

    # ranking
    value = -1
    rank = 0
    ClanScoreEntry.all(:trophy  => "most_points", :order => [ :value.desc ]).each {|c|
        rank += 1 unless value == c.value
        value = c.value
        c.rank = rank
        c.save
    }

    return true
end
