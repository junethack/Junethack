class GnollhackAdditionalAttributes2026 < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :versionstart, :string
    add_column :junk_games, :versionstart, :string
    add_column :start_scummed_games, :versionstart, :string

    add_column :games, :editstart, :string
    add_column :junk_games, :editstart, :string
    add_column :start_scummed_games, :editstart, :string
  end
end
