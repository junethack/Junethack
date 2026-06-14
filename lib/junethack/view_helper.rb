module ViewHelper
  def variant_day_table(title, query_type, url_prefix, hide_zero, border_top)
    data_by_day = ActivityQueries.send("#{query_type}_by_variant_and_day")
    data_total = ActivityQueries.send("#{query_type}_by_variant")
    haml :_variant_day_table, locals: {
      title:,
      data_by_day:,
      data_total:,
      url_prefix:,
      hide_zero:,
      border_top:
    }
  end
end
