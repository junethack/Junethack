class ReseedEvilhackTrophies < ActiveRecord::Migration[7.0]
  # Recreate the EvilHack trophy definitions so existing databases pick up
  # the 2026 additions (Tal'Gath, quest leaders/nemeses of the Convict,
  # Infidel and Druid quests, location and conduct trophies).
  # Trophy rows are pure definitions; score entries reference trophies by
  # name, so deleting and reseeding is safe.
  # Afterwards run `rake update:rescore_evilhack` to award the new trophies
  # for already recorded games.
  def up
    Trophy.where(variant: 'evh').delete_all
    Trophy.check_trophies_for_variant 'evilhack'
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end
end
