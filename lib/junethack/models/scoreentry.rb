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

    def Individualtrophy.add(user_id, trophy, icon)
      # check for existence
      c = Individualtrophy.first(:user_id => user_id,
              :trophy => trophy,
              :icon => icon)
      # achievement doesn't exist yet, create it
      if not c then
        Individualtrophy.create(user_id: user_id,
                                trophy: trophy,
                                icon: icon)
        text = Trophy.first(trophy: trophy).text
        user = User.first(:id => user_id).login
        event_text = "Achievement \"#{text}\" unlocked by #{user}!"

        sightseeing_tour = /Sightseeing Tour: finish a game in (one|two|three|four) variants?/
        globetrotter = /Globetrotter: get a trophy in (one|two|three|four) variants?/
        spam_protection = text =~ sightseeing_tour || text =~ globetrotter
        first_day_of_tournament = Time.at($tournament_starttime).to_date == Date.today
        if first_day_of_tournament && spam_protection
          puts "Spam protection for #{event_text}"
        else
          Event.create(text: event_text)
        end
      end
    end
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

# competition clan trophies history
class ClanScoreHistory
    include DataMapper::Resource
    belongs_to :clan

    property :id,        Serial, :key => true
    property :trophy,    String
    property :value,     Integer
    property :icon,      String
    property :rank,      Integer, :default => -1
    property :points,    Float, :default => 0.0
    property :created_at, DateTime
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

DataMapper::MigrationRunner.migration( 1, :fix_unique_indexes ) do
  up do
    # belongs_to, :key => true doesn't correctly creates unique indexes
    execute 'DROP INDEX "unique_scoreentries_key";'
    execute 'CREATE UNIQUE INDEX "unique_scoreentries_key" ON "scoreentries" ("variant", "trophy", "user_id");'

    execute 'DROP INDEX "unique_individualtrophies_key";'
    execute 'CREATE UNIQUE INDEX "unique_individualtrophies_key" ON "individualtrophies" ("trophy", "user_id");'

    execute 'DROP INDEX "unique_clan_score_entries_key";'
    execute 'CREATE UNIQUE INDEX "unique_clan_score_entries_key" ON "clan_score_entries" ("trophy", "clan_name");'

    execute 'DROP INDEX "unique_competition_score_entries_key";'
    execute 'CREATE UNIQUE INDEX "unique_competition_score_entries_key" ON "competition_score_entries" ("trophy", "variant", "user_id");'
  end
end
