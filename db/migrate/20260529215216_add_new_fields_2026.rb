class AddNewFields2026 < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :rerolls, :integer, default: 0
    add_column :junk_games, :rerolls, :integer, default: 0
    add_column :start_scummed_games, :rerolls, :integer, default: 0

    add_column :games, :achieve2, :string, limit: 255
    add_column :junk_games, :achieve2, :string, limit: 255
    add_column :start_scummed_games, :achieve2, :string, limit: 255
  end
end
