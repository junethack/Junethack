module ViewHelper
  def active_filters_suffix
    return "" unless @users&.any? || @clans&.any?
    parts = []
    parts << "u=#{@users.sort.join(',')}" if @users&.any?
    parts << "c=#{@clans.sort.join(',')}" if @clans&.any?
    parts << "m=#{@mode}"
    "_#{parts.join('_')}"
  end

  def remove_url(remove_user: nil, remove_clan: nil)
    users = (@users || []) - [remove_user].compact
    clans = (@clans || []) - [remove_clan].compact
    return request.path_info unless users.any? || clans.any?
    params = []
    params << "users=#{users.join(',')}" if users.any?
    params << "clans=#{clans.join(',')}" if clans.any?
    params << "mode=#{@mode}"
    "#{request.path_info}?#{params.join('&')}"
  end

  def filter_active?
    filter_user_ids.any?
  end

  def filtered_tournament_games
    ids = filter_user_ids
    return Game.where.not(user_id: nil) if ids.empty?
    @mode == "include" ? Game.where(user_id: ids).where.not(user_id: nil) : Game.where.not(user_id: ids).where.not(user_id: nil)
  end

  def filtered_start_scummed_games
    ids = filter_user_ids
    return StartScummedGame.where.not(user_id: nil) if ids.empty?
    @mode == "include" ? StartScummedGame.where(user_id: ids).where.not(user_id: nil) : StartScummedGame.where.not(user_id: ids).where.not(user_id: nil)
  end

  def filter_sql_clause
    ids = filter_user_ids
    return "" if ids.empty?
    ids_str = ids.join(",")
    @mode == "include" ? "AND user_id IN (#{ids_str})" : "AND user_id NOT IN (#{ids_str})"
  end

  def filter_title_suffix
    if @users&.any?
      " for user#{@users.size > 1 ? 's' : ''} #{@users.join(', ')}"
    elsif @clans&.any?
      " for clan#{@clans.size > 1 ? 's' : ''} #{@clans.join(', ')}"
    else
      ""
    end
  end

  private

  def filter_user_ids
    return [] unless (@users&.any? || @clans&.any?) && %w[include exclude].include?(@mode)
    @users&.any? ? User.where(login: @users).pluck(:id) : User.where(clan_name: @clans).pluck(:id)
  end
end
