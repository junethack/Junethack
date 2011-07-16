require 'dm-migrations'
require 'dm-migrations/migration_runner'

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

class Individualtrophy
    include DataMapper::Resource
    belongs_to :user,   :key => true

    property :trophy,    String, :key => true
    property :icon,      String
end

class ClanScoreEntry
    include DataMapper::Resource
    belongs_to :clan,   :key => true

    property :trophy,    String, :key => true
    property :value,     Integer
    property :icon,      String
    property :rank,      Integer, :default => -1
end


#DataMapper::MigrationRunner.migration( 1, :create_scoreboard_indexes ) do
#  up do
#    execute 'CREATE INDEX "index_games_endtime_user_id" ON "games" ("endtime" desc, "user_id");'
#    execute 'CREATE INDEX "index_games_highscore" ON "games" ("user_id", "death", "server_id", "points","endtime");'
#  end
#  down do
#    execute 'DROP INDEX "index_games_endtime_user_id"';
#    execute 'DROP INDEX "index_games_highscore"';
#  end
#end
#
#DataMapper::MigrationRunner.migrate_up!
