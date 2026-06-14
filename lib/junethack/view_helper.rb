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
    return "/activity" unless users.any? || clans.any?
    params = []
    params << "users=#{users.join(',')}" if users.any?
    params << "clans=#{clans.join(',')}" if clans.any?
    params << "mode=#{@mode}"
    "/activity?#{params.join('&')}"
  end
end
