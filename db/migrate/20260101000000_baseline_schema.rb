class BaselineSchema < ActiveRecord::Migration[7.0]
  def up
    require 'load_structure_sql'
    load_structure_sql(ActiveRecord::Base.connection)
    News.seed_news
    Server.seed_servers
    Trophy.seed_trophies
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
