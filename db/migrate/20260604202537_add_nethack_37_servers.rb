class AddNethack37Servers < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      INSERT INTO servers (name, url, xlogurl, xloglastmodified, variant, xlogcurrentoffset, configfileurl)
      VALUES
        ('hdf_nh37', 'https://www.hardfought.org/nethack', 'https://www.hardfought.org/xlogfiles/nethack37/xlogfile',
         '2000-01-01', 'NetHack 3.7.0-hdf', 105997167,
         'https://www.hardfought.org/userdata/random_user_initial/random_user/nh343/random_user.nh343rc'),
        ('euhdf_nh37', 'https://eu.hardfought.org/nethack', 'https://eu.hardfought.org/xlogfiles/nethack37/xlogfile',
         '2000-01-01', 'NetHack 3.7.0-hdf', 55004501,
         'https://eu.hardfought.org/userdata/random_user_initial/random_user/nh343/random_user.nh343rc'),
        ('auhdf_nh37', 'https://au.hardfought.org/nethack', 'https://au.hardfought.org/xlogfiles/nethack37/xlogfile',
         '2000-01-01', 'NetHack 3.7.0-hdf', 10013940,
         'https://au.hardfought.org/userdata/random_user_initial/random_user/nh343/random_user.nh343rc')
    SQL

    execute <<-SQL
      INSERT INTO accounts (user_id, server_id, name, verified)
      SELECT DISTINCT ON (a.user_id, s.id) a.user_id, s.id, a.name, true
      FROM accounts a
      JOIN servers s ON s.name IN ('hdf_nh37', 'euhdf_nh37', 'auhdf_nh37')
      JOIN servers existing_s ON existing_s.id = a.server_id
      WHERE existing_s.name LIKE 'hdf_%' OR existing_s.name LIKE 'euhdf_%' OR existing_s.name LIKE 'auhdf_%'
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM accounts WHERE server_id IN (SELECT id FROM servers WHERE name IN ('hdf_nh37', 'euhdf_nh37', 'auhdf_nh37'))
    SQL

    execute <<-SQL
      DELETE FROM servers WHERE name IN ('hdf_nh37', 'euhdf_nh37', 'auhdf_nh37')
    SQL
  end
end
