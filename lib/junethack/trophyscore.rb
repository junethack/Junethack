require 'helper'

class TrophyScore

def most_ascensions(variant=nil)
    return sql_select("select distinct * from (select count(1) as ascension, user_id, (select name from users where user_id = id) as user, endtime from games where version = ? and user_id is not null and ascended = true group by user_id) where ascension = (select max(max_ascension) from (select count(1) as max_ascension from games where version = ? and user_id is not null and ascended = true group by user_id));", variant, variant)
end

def highest_scoring_ascension(variant=nil)
    return sql_select("select distinct points, user_id, (select name from users where user_id = id) as user, endtime from games where version = ? and user_id is not null and ascended = true and points = (select max(points) from games where version = ? and user_id is not null and ascended = true) group by points, user_id order by endtime", variant, variant)
end

def lowest_scoring_ascension(variant=nil)
    return sql_select("select distinct points, user_id, (select name from users where user_id = id) as user, endtime from games where version = ? and user_id is not null and ascended = true and points = (select min(points) from games where version = ? and user_id is not null and ascended = true) order by endtime", variant, variant)
end

def most_conducts_ascension(variant=nil)
    return sql_select("select distinct nconducts, user_id, (select name from users where user_id = id) as user, endtime from games where version = ? and user_id is not null and ascended = true and nconducts = (select max(nconducts) from games where version = ? and user_id is not null and ascended = true)", variant, variant)
end

# returns the fastest realtime duration of an ascension in milliseconds
def fastest_ascension_realtime(variant=nil)
    return sql_select("SELECT DISTINCT (endtime - starttime) AS duration, user_id, (SELECT name FROM users WHERE user_id = id) AS user, endtime FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended = true AND duration = (SELECT min(endtime-starttime) FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended = true) ORDER BY endtime", variant, variant)
end

# returns the fastest in-game duration of an ascension in milliseconds
def fastest_ascension_gametime(variant=nil)
    return sql_select("SELECT DISTINCT turns AS duration, user_id, endtime FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended = true AND turns = (SELECT min(turns) FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended = true) ORDER BY endtime", variant, variant)
end

# returns a list of all ascension streaks per variant
def ascension_streaks(variant=nil)
    games = sql_select("SELECT ascended, user_id, server_id, endtime, 0 AS streaks FROM games WHERE version = ? AND user_id IN (SELECT user_id FROM games WHERE ascended = true) ORDER BY server_id, endtime DESC", variant)

    # calculate streaks
    streaks = Hash.new(0)
    max_streaks = Hash.new(0)
    # streaks are per server and per variant
    server_id = 0
    games.each { |game|
        streaks[game.user_id] = 0 if !game.ascended or game.server_id != server_id
        server_id = game.server_id

        streaks[game.user_id] += 1 if game.ascended

        if streaks[game.user_id] > max_streaks[game.user_id]
            max_streaks[game.user_id] = streaks[game.user_id]
        end
    }

    # construct return object
    streaks = sql_select("select user_id, (select name from users where user_id = id) as user, endtime, 0 as streaks from games where version = ? and user_id in (select user_id from games where ascended = true) group by user_id order by endtime desc", variant)
    return streaks.delete_if {|game|
        game.streaks = max_streaks[game.user_id]
        game.streaks == 1
    }.sort_by {|game| -game.streaks }
end

def longest_ascension_streaks(variant=nil)
    streaks = ascension_streaks(variant)

    highest_streaks = 0
    return streaks.delete_if { |s|
        if s.streaks > highest_streaks
            highest_streaks = s.streaks
            false
        else
            true
        end
    }
end

end
