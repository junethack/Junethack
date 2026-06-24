class ReseedXnethackTrophies < ActiveRecord::Migration[7.0]
  def up
    Trophy.where(variant: 'xnh').delete_all
    Trophy.check_trophies_for_variant 'xnethack'
  end

  def down
  end
end
