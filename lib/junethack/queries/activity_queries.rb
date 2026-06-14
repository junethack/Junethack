Point = Data.define(:datum, :count)

class ActivityQueries
  def self.finished_games_by_variant_and_day
    Game.where.not(user_id: nil)
        .where("endtime >= ? AND endtime < ?", $tournament_starttime, $tournament_endtime)
        .group(:version, "to_timestamp(endtime)::date::text")
        .count
  end

  def self.finished_games_by_variant
    Game.where.not(user_id: nil)
        .group(:version)
        .count
  end

  def self.unique_players_by_variant_and_day
    Game.where.not(user_id: nil)
        .where("endtime >= ? AND endtime < ?", $tournament_starttime, $tournament_endtime)
        .group(:version, "to_timestamp(endtime)::date::text")
        .distinct
        .count(:user_id)
  end

  def self.unique_players_by_variant
    Game.where.not(user_id: nil)
        .group(:version)
        .distinct
        .count(:user_id)
  end

  def self.ascensions_by_variant_and_day
    Game.where.not(user_id: nil)
        .where("endtime >= ? AND endtime < ?", $tournament_starttime, $tournament_endtime)
        .where(ascended: true)
        .group(:version, "to_timestamp(endtime)::date::text")
        .count
  end

  def self.ascensions_by_variant
    Game.where.not(user_id: nil)
        .where(ascended: true)
        .group(:version)
        .count
  end

  def self.finished_games_per_day
    Game.where.not(user_id: nil)
        .select("to_timestamp(endtime)::date AS datum, count(1) as count")
        .group("datum")
        .order("datum ASC")
        .map { |r| Point.new(r.datum, r.count) }
  end

  def self.total_finished_games
    Game.where.not(user_id: nil).count
  end

  def self.ascensions_per_day_with_zeros
    # Ugly SQL to also get days with zero ascensions. Will only work
    # as long there are any games for each day
    Game.find_by_sql(
      "SELECT days.datum, endtime, count FROM " \
      "(SELECT max(endtime) AS endtime, to_timestamp(endtime)::date AS datum FROM games GROUP BY datum) AS days " \
      "LEFT JOIN " \
      "(SELECT datum, count(1) AS count FROM " \
      "(SELECT to_timestamp(endtime)::date AS datum FROM games WHERE user_id IS NOT NULL AND ascended = TRUE) AS ascended_games " \
      "GROUP BY datum) counts " \
      "ON counts.datum = days.datum"
    )
  end

  def self.total_ascensions
    Game.where.not(user_id: nil)
        .where(ascended: true).count
  end

  def self.new_users_by_day
    User.group("date(created_at)")
        .pluck("date(created_at), count(1)")
        .map { |d, c| Point.new(Date.parse(d.to_s), c) }
  end

  def self.total_users
    User.count
  end
end
