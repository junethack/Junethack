require 'helper'

class TrophyScore

  def most_ascensions(variant=nil)
    return (repository.adapter.select "SELECT distinct * FROM (select count(1) as ascension, user_id, max(endtime) as endtime FROM games where version = ? and user_id is not null and ascended='t' group by user_id) a where ascension = (select max(max_ascension) FROM (select count(1) as max_ascension FROM games where version = ? and user_id is not null and ascended='t' group by user_id) max_asc) ;", variant, variant)
  end

  def highest_scoring_ascension(variant=nil)
    return repository.adapter.select "SELECT distinct points, user_id, max(endtime) as endtime FROM games where version = ? and user_id is not null and ascended='t' and points = (select max(points) FROM games where version = ? and user_id is not null and ascended='t') group by points, user_id ORDER BY endtime", variant, variant
  end

  def lowest_scoring_ascension(variant=nil)
    return repository.adapter.select "SELECT DISTINCT points, user_id, endtime FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended='t' AND points = (SELECT MIN(points) FROM games WHERE version = ? and user_id is not null and ascended='t') ORDER BY endtime", variant, variant
  end

  def most_conducts_ascension(variant=nil)
    return repository.adapter.select "SELECT DISTINCT nconducts, user_id, max(endtime) as endtime FROM games where version = ? and user_id is not null and ascended='t' and nconducts = (select max(nconducts) FROM games where version = ? and user_id is not null and ascended='t')", variant, variant
  end

  # returns the fastest realtime duration of an ascension in milliseconds
  def fastest_ascension_realtime(variant=nil)
    return repository.adapter.select "SELECT * FROM (SELECT DISTINCT (endtime-starttime) AS duration, user_id, endtime FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended='t') abc ORDER BY duration DESC, endtime LIMIT 1", variant
  end

# returns the fastest in-game duration of an ascension in milliseconds
def fastest_ascension_gametime(variant=nil)
    return repository.adapter.select "SELECT DISTINCT turns AS duration, user_id, endtime FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended='t' AND turns = (select min(turns) FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended='t') ORDER BY endtime", variant, variant
end

# returns a list of all ascension streaks per variant
def ascension_streaks(variant=nil)
  sql = <<-SQL
    SELECT ascended,
          user_id,
          server_id,
          endtime,
          0 AS streaks
    FROM games
    WHERE version = ?
    AND   user_id IN (SELECT user_id FROM games WHERE ascended = 't')
    ORDER BY server_id,
            endtime DESC
  SQL

  games = repository.adapter.select(sql, variant)

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
  sql = <<-SQL
    SELECT user_id,
        (SELECT login FROM users WHERE user_id = id) AS USER,
        max(endtime) AS endtime,
        0 AS streaks
    FROM games
    WHERE version = ?
    AND   user_id IN (SELECT user_id FROM games WHERE ascended = 't')
    GROUP BY user_id
    ORDER BY max(endtime) DESC
  SQL

  streaks = repository.adapter.select(sql, variant)
  return streaks.delete_if { |game|
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
