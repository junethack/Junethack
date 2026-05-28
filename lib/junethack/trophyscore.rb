require 'helper'

class TrophyScore
  def most_ascensions(variant=nil)
    sql = <<-SQL
			SELECT DISTINCT *
			FROM (SELECT COUNT(1) AS ascension,
									user_id,
									(SELECT login FROM users WHERE user_id = id) AS USER,
									max(endtime) as endtime
						FROM games
						WHERE VERSION = ?
						AND   user_id IS NOT NULL
						AND   ascended = TRUE
						GROUP BY user_id) AS ascension
			WHERE ascension = (SELECT MAX(max_ascension)
			FROM (SELECT COUNT(1) AS max_ascension FROM games WHERE VERSION = ?
			AND user_id IS NOT NULL AND ascended = TRUE GROUP BY user_id
			) AS max_ascension)
    SQL
    return sql_select(sql, variant, variant)
  end

  def highest_scoring_ascension(variant=nil)
    sql = <<-SQL
			SELECT DISTINCT points,
						user_id,
						(SELECT login FROM users WHERE user_id = id) AS USER,
						MAX(endtime) AS endtime
			FROM games
			WHERE version = ?
			AND   user_id IS NOT NULL
			AND   ascended = TRUE
			AND   points = (SELECT MAX(points)
											FROM games
											WHERE VERSION = ?
											AND   user_id IS NOT NULL
											AND   ascended = TRUE)
			GROUP BY points,
							user_id
			ORDER BY endtime
    SQL
    return sql_select(sql, variant, variant)
  end

  def lowest_scoring_ascension(variant=nil)
    return sql_select("SELECT DISTINCT points, user_id, (SELECT name FROM users WHERE user_id = id) AS user, endtime FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended = true AND points = (SELECT min(points) FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended = true) ORDER BY endtime", variant, variant)
  end

  def most_conducts_ascension(variant=nil)
    return sql_select("select distinct nconducts, user_id, (select name from users where user_id = id) as user, max(endtime) as endtime from games where version = ? and user_id is not null and ascended = true and nconducts = (select max(nconducts) from games where version = ? and user_id is not null and ascended = true", variant, variant)
  end

  # returns the fastest realtime duration of an ascension in milliseconds
  def fastest_ascension_realtime(variant=nil)
      return sql_select("SELECT * FROM (SELECT DISTINCT (endtime - starttime) AS duration, user_id, endtime FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended = true) abc ORDER BY duration DESC, endtime LIMIT 1", variant)
  end

  # returns the fastest in-game duration of an ascension in milliseconds
  def fastest_ascension_gametime(variant=nil)
    return sql_select("SELECT DISTINCT turns AS duration, user_id, endtime FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended = true AND turns = (SELECT min(turns) FROM games WHERE version = ? AND user_id IS NOT NULL AND ascended = true) ORDER BY endtime", variant, variant)
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
      AND   user_id IN (SELECT user_id FROM games WHERE ascended = true)
      AND   user_id IN (SELECT user_id FROM games WHERE ascended = true)
      ORDER BY server_id,
              endtime DESC
    SQL

    # calculate streaks
    streaks = Hash.new(0)
    max_streaks = Hash.new(0)
    # streaks are per server and per variant
    server_id = 0

    games = sql_select(sql, variant)
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
          (SELECT login FROM users WHERE user_id = id) AS user,
          max(endtime) AS endtime,
          0 AS streaks
      FROM games
      WHERE version = ?
      AND   user_id IN (SELECT user_id FROM games WHERE ascended = true)
      GROUP BY user_id
      ORDER BY max(endtime) DESC
    SQL

    streaks = sql_select(sql, variant)
    return streaks.delete_if { |game|
      game.streaks = max_streaks[game.user_id]
      game.streaks == 1
    }.sort_by { |game| -game.streaks }
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
