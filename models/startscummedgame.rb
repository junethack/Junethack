require 'dm-migrations'
require 'dm-migrations/migration_runner'

class StartScummedGame
    include DataMapper::Resource
    belongs_to :server
    belongs_to :user,   :required => false

    property :id,        Serial
    property :name,      String
    property :deaths,    Integer
    property :deathlev,  Integer
    property :realtime,  Integer
    property :turns,     Integer
    property :birthdate, String
    property :conduct,   String
    property :nconducts, Integer,
     :default => lambda { |r, p| (Integer r.conduct).to_s(2).count("1") } # count the number of bits set in conduct
    property :role,      String
    property :deathdnum, Integer
    property :gender,    String
    property :gender0,   String
    property :uid,       Integer
    property :maxhp,     Integer
    property :points,    Integer
    property :deathdate, String
    property :version,   String
    property :align,     String
    property :align0,    String
    property :starttime, Integer
    property :endtime,   Integer
    property :achieve,   String
    property :nachieves, Integer
    property :hp,        Integer
    property :maxlvl,    Integer
    property :death,     String
    property :race,      String
    property :flags,     String
    property :ascended,  Boolean,
     :default => lambda { |r, p| r.death.start_with? "ascended" or r.death == "escaped (with amulet)" or r.death.start_with? "defied" }

    before :valid?, :trim_death
    # we need to limit the size of deaths
    def trim_death(context = :default)
       self.death = death[0,255]
    end

    #acehack/unnethack-specific properties
    property :carried,  String
    property :event,    String

    #acehack/unnethack-specific properties
    property :deathdname, String
    property :dlev_name,  String
    property :elbereths,  Integer, :default => -1

end


DataMapper::MigrationRunner.migration( 1, :transfer_start_scummed_games ) do
  up do
    execute "insert into start_scummed_games select * from games where turns <= 10 and death in ('escaped', 'quit');"
    execute "delete from games where turns <= 10 and death in ('escaped', 'quit');"
    execute "reindex;"
    execute "vacuum;"
  end
  down do
  end
end
