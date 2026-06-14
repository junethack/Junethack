Point = Data.define(:datum, :count)

class ActivityQueries
  def self.filtered_scope(users: nil, clans: nil, mode: "include")
    scope = Game.where.not(user_id: nil)
    return scope unless has_filters?(users:, clans:, mode:)

    user_id = User.where(login: users).pluck(:id)
    if mode == "include"
      return scope.where(user_id:) if users&.any?
      return scope.joins(:user).where(users: { clan_name: clans }) if clans&.any?
    else
      return scope.where.not(user_id:) if users&.any?
      return scope.joins(:user).where.not(users: { clan_name: clans }) if clans&.any?
    end

    scope
  end

  def self.has_filters?(users: nil, clans: nil, mode: "include")
    (users&.any? || clans&.any?) && %w[include exclude].include?(mode)
  end

  def self.finished_games_by_variant_and_day(users: nil, clans: nil, mode: "include")
    filtered_scope(users:, clans:, mode:)
        .where("endtime >= ? AND endtime < ?", $tournament_starttime, $tournament_endtime)
        .group(:version, "to_timestamp(endtime)::date::text")
        .count
  end

  def self.finished_games_by_variant(users: nil, clans: nil, mode: "include")
    filtered_scope(users:, clans:, mode:)
        .group(:version)
        .count
  end

  def self.unique_players_by_variant_and_day(users: nil, clans: nil, mode: "include")
    filtered_scope(users:, clans:, mode:)
        .where("endtime >= ? AND endtime < ?", $tournament_starttime, $tournament_endtime)
        .group(:version, "to_timestamp(endtime)::date::text")
        .distinct
        .count(:user_id)
  end

  def self.unique_players_by_variant(users: nil, clans: nil, mode: "include")
    filtered_scope(users:, clans:, mode:)
        .group(:version)
        .distinct
        .count(:user_id)
  end

  def self.ascensions_by_variant_and_day(users: nil, clans: nil, mode: "include")
    filtered_scope(users:, clans:, mode:)
        .where("endtime >= ? AND endtime < ?", $tournament_starttime, $tournament_endtime)
        .where(ascended: true)
        .group(:version, "to_timestamp(endtime)::date::text")
        .count
  end

  def self.ascensions_by_variant(users: nil, clans: nil, mode: "include")
    filtered_scope(users:, clans:, mode:)
        .where(ascended: true)
        .group(:version)
        .count
  end

  def self.finished_games_per_day(users: nil, clans: nil, mode: "include")
    filtered_scope(users:, clans:, mode:)
        .select("to_timestamp(endtime)::date AS datum, count(1) as count")
        .group("datum")
        .order("datum ASC")
        .map { |r| Point.new(r.datum, r.count) }
  end

  def self.total_finished_games(users: nil, clans: nil, mode: "include")
    filtered_scope(users:, clans:, mode:).count
  end

  def self.ascensions_per_day_with_zeros(users: nil, clans: nil, mode: "include")
    if has_filters?(users:, clans:, mode:)
      filtered_scope(users:, clans:, mode:)
          .where(ascended: true)
          .select("to_timestamp(endtime)::date AS datum, count(1) as count")
          .group("datum")
          .order("datum ASC")
          .map { |r| Point.new(r.datum, r.count || 0) }
    else
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
  end

  def self.total_ascensions(users: nil, clans: nil, mode: "include")
    filtered_scope(users:, clans:, mode:)
        .where(ascended: true).count
  end

  def self.ascensions_by_player(users: nil, clans: nil, mode: "include")
    filtered_scope(users:, clans:, mode:)
        .where(ascended: true)
        .joins(:user)
        .group("users.login")
        .order("count_all DESC, lower(login) ASC")
        .count
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
