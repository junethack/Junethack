require 'helper'

class TrophyScore

def most_ascensions(variant=nil)
    return (repository.adapter.select "select distinct * from (select count(1) as ascension, user_id, (select name from users where user_id = id) as user, endtime from games where version = ? and user_id is not null and ascended='t' group by user_id) where ascension = (select max(max_ascension) from (select count(1) as max_ascension from games where version = ? and user_id is not null and ascended='t' group by user_id));", variant, variant)
end

def highest_scoring_ascension(variant=nil)
    return repository.adapter.select "select distinct points, user_id, (select name from users where user_id = id) as user, endtime from games where version = ? and user_id is not null and ascended='t' and points = (select max(points) from games where version = ? and user_id is not null and ascended='t') group by points, user_id order by endtime", variant, variant
end

def lowest_scoring_ascension(variant=nil)
    return repository.adapter.select "select distinct points, user_id, (select name from users where user_id = id) as user, endtime from games where version = ? and user_id is not null and ascended='t' and points = (select min(points) from games where version = ? and user_id is not null and ascended='t') order by endtime", variant, variant
end

def most_conducts_ascension(variant=nil)
    return repository.adapter.select "select distinct nconducts, user_id, (select name from users where user_id = id) as user, endtime from games where version = ? and user_id is not null and ascended='t' and nconducts = (select max(nconducts) from games where version = ? and user_id is not null and ascended='t')", variant, variant
end

# returns the fastest realtime duration of an ascension in milliseconds
def fastest_ascension_realtime(variant=nil)
    return repository.adapter.select "select distinct (endtime-starttime) as duration, user_id, (select name from users where user_id = id) as user, endtime from games where version = ? and user_id is not null and ascended='t' and duration = (select min(endtime-starttime) from games where version = ? and user_id is not null and ascended='t') order by endtime", variant, variant
end

# returns the fastest in-game duration of an ascension in milliseconds
def fastest_ascension_gametime(variant=nil)
    return repository.adapter.select "select distinct turns as duration, user_id, (select name from users where user_id = id) as user, endtime from games where version = ? and user_id is not null and ascended='t' and duration = (select min(turns) from games where version = ? and user_id is not null and ascended='t') order by endtime", variant, variant
end

# returns a list of all ascension streaks per variant
def ascension_streaks(variant=nil)
    games = repository.adapter.select "select ascended, user_id, endtime, 0 as streaks from games where version = ? and user_id in (select user_id from games where ascended='t') order by endtime desc", variant

    # calculate streaks
    streaks = Hash.new(0)
    max_streaks = Hash.new(0)
    games.each {|game|
        streaks[game.user_id] += 1 if game.ascended == 't'

        if streaks[game.user_id] > max_streaks[game.user_id]
            max_streaks[game.user_id] = streaks[game.user_id]
        end

        streaks[game.user_id] = 0 if game.ascended == 'f'
    }

    # construct return object
    streaks = repository.adapter.select "select user_id, (select name from users where user_id = id) as user, endtime, 0 as streaks from games where version = ? and user_id in (select user_id from games where ascended='t') group by user_id order by endtime desc", variant
    return streaks.delete_if {|game|
        game.streaks = max_streaks[game.user_id]
        game.streaks == 1
    }.sort_by {|game| -game.streaks }
end

def longest_ascension_streaks(variant=nil)
    streaks = ascension_streaks(variant)

    highest_streaks = 0
    return streaks.delete_if {|s|
        if s.streaks > highest_streaks
            highest_streaks = s.streaks
            false
        else
            true
        end
    }
end

end
