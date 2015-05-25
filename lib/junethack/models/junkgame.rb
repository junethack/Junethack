require 'dm-migrations'
require 'dm-migrations/migration_runner'

class JunkGame
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
     :default => lambda { |r, p| (Integer(r.conduct) & 4095).to_s(2).count("1") } # count the number of bits set in conduct
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

    # acehack/unnethack-specific properties
    property :carried,  String
    property :event,    String

    # acehack/unnethack-specific properties
    property :deathdname, String
    property :dlev_name,  String
    property :elbereths,  Integer, :default => -1

    property :xplevel, Integer, :default => 0
    property :exp,     Integer, :default => 0
    property :mode,    String
    property :gold,    Integer, :default => -1

    # nethack4-specific properties
    property :charname, String
    property :extrinsic, String
    property :intrinsic, String
    property :temporary, String
    property :rngseed,   String
    property :dumplog,   String
    property :birthoption, String
    property :starttimeus, Integer
    property :endtimeus,   Integer

    # dnethack-specific properties
    property :dnetachieve, String

    # nh4k-specific properties
    property :variant, String

    # SlashTHEM-specific properties
    property :modes, String
end
