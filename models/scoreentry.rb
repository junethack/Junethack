require 'dm-migrations'
require 'dm-migrations/migration_runner'

# variant-specific user trophies
class Scoreentry
    include DataMapper::Resource
    belongs_to :user,   :key => true

    property :variant,   String, :key => true
    property :trophy,    String, :key => true # trophy or competition name
    property :trophy_display, String
    property :value,     String
    property :value_display,  String
    property :icon,      String
    property :endtime,   Integer # endtime of game with which this trophy was achieved
end

# cross-variant user trophies
class Individualtrophy
    include DataMapper::Resource
    belongs_to :user,   :key => true

    property :trophy,    String, :key => true
    property :icon,      String
end

# competition clan trophies
class ClanScoreEntry
    include DataMapper::Resource
    belongs_to :clan,   :key => true

    property :trophy,    String, :key => true
    property :value,     Integer
    property :icon,      String
    property :rank,      Integer, :default => -1
    property :points,    Float, :default => 0.0
end

# variant-specific competition user trophies
class CompetitionScoreEntry
    include DataMapper::Resource
    belongs_to :user,   :key => true

    property :trophy,    String, :key => true
    property :variant,   String, :key => true
    property :value,     Integer
    property :icon,      String
    property :rank,      Integer, :default => -1
end

# we don't have that trophy in the 2011 tournament
DataMapper::MigrationRunner.migration( 1, :delete_most_variant_trophy_combinations ) do
  up do
    ClanScoreEntry.all(:trophy => 'most_variant_trophy_combinations').destroy
  end
end

# unnethack specific trophies aren't tracked because of an old version on the servers
DataMapper::MigrationRunner.migration( 2, :unnethack_manual_trophies ) do
  up do
    # http://un.nethack.nu/user/Mortuis/dumps/Mortuis.1312367137.txt.html
    execute "insert into scoreentries (variant, trophy, user_id) values ('UNH-3.5.4','defeated_croesus',70);"
    # http://un.nethack.nu/user/BlastHardcheese/dumps/BlastHardcheese.1313108554.txt.html
    execute "insert into scoreentries (variant, trophy, user_id) values ('UNH-3.5.4','defeated_one_eyed_sam',284);"

    # http://un.nethack.nu/user/aaxelb/dumps/aaxelb.1312059308.txt.html
    execute "insert into scoreentries (variant, trophy, user_id) values ('UNH-3.5.4','ascended_with_all_invocation_items',55);"
    # http://un.nethack.nu/user/Alice/dumps/Alice.1311631675.txt.html
    execute "insert into scoreentries (variant, trophy, user_id) values ('UNH-3.5.4','ascended_with_all_invocation_items',6);"
    # http://un.nethack.nu/user/BlastHardcheese/dumps/BlastHardcheese.1313108554.txt.html
    execute "insert into scoreentries (variant, trophy, user_id) values ('UNH-3.5.4','ascended_with_all_invocation_items',284);"
    # http://un.nethack.nu/user/spontiff/dumps/spontiff.1311782654.txt.html
    execute "insert into scoreentries (variant, trophy, user_id) values ('UNH-3.5.4','ascended_with_all_invocation_items',25);"

    # no UnNetHack specific trophies for this ascensions
    # http://un.nethack.nu/user/ishanyx/dumps/ishanyx.1311832452.txt.html
    # http://un.nethack.nu/user/stenno/dumps/stenno.1312918341.txt.html
  end
end
