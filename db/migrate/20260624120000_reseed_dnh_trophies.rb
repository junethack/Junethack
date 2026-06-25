class ReseedDnhTrophies < ActiveRecord::Migration[7.0]
  # Fix notnotdnethack/notdnethack/dnethack trophy icons that reference
  # outdated long filenames (identical copies of undefined.png) instead of
  # the proper short filenames used by the current code.
  def up
    Trophy.where(variant: 'nndnh').delete_all
    Trophy.where(variant: 'ndnh').delete_all
    Trophy.where(variant: 'dnh').delete_all

    Trophy.check_trophies_for_variant 'notnotdnethack'
    Trophy.check_trophies_for_variant 'notdnethack'
    Trophy.check_trophies_for_variant 'dnethack'
  end

  def down
  end
end
