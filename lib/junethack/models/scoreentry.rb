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

DataMapper::MigrationRunner.migration( 1, :junethack2012_int_max_ascension ) do
  up do
    execute "update clan_score_entries set value = 9223372036854775807 where trophy = 'most_points' and clan_name = 'ItExplodes';"
  end
end
