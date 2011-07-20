require 'helper'

class UserScore

# http://nethackwiki.com/wiki/User:Kerio/Junethack#Per-variant
# Per-variant
# Competitions
#  [X] Most ascensions
#  [X] Longest ascension streak
#  [X] Fastest ascension (gametime)
#  [X] Fastest ascension (realtime)
#  [X] Highest scoring ascension
#  [X] Lowest scoring ascension
#  [ ] Lowest scoring ascension modulo depth
#  [X] Most conducts in a single ascension

attr_reader :variants

def initialize(id)
    @id = id
    @variants = helper_get_variants_for_user(@id)
end

def most_ascensions(variant=nil)
    return (repository.adapter.select "select count(1) from games where version = ? and user_id = ?  and ascended='t'", variant, @id)[0]
end

def highest_scoring_ascension(variant=nil)
    return repository.adapter.select "select max(points) from games where version = ? and user_id = ? and ascended='t'", variant, @id
end

def lowest_scoring_ascension(variant=nil)
    return repository.adapter.select "select min(points) from games where version = ? and user_id = ? and ascended='t'", variant, @id
end

def most_conducts_ascension(variant=nil)
    return repository.adapter.select "select max(nconducts) from games where version = ? and user_id = ? and ascended='t'", variant, @id
end

# returns the min realtime duration of an ascension in milliseconds
def fastest_ascension_realtime(variant=nil)
    return parse_seconds((repository.adapter.select "select min(endtime-starttime) from games where version = ? and user_id = ? and ascended='t'", variant, @id)[0])
end

# returns the min in-game duration of an ascension in milliseconds
def fastest_ascension_gametime(variant=nil)
    return (repository.adapter.select "select min(turns) from games where version = ? and user_id = ? and ascended='t'", variant, @id)[0]
end

def longest_ascension_streak(variant=nil)
    games_deaths = (repository.adapter.select "select death from games where version = ? and user_id = ? order by endtime desc", variant, @id)

    max_asc = 0;
    asc = 0;
    games_deaths.each {|death|
        if death == 'ascended'
            asc += 1
        else
            max_asc = asc if asc > max_asc 
            asc = 0
        end
    }
    return max_asc
end

end
