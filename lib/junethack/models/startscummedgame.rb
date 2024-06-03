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
    property :conduct,   String, :default => '0'
    property :nconducts, Integer,
     :default => lambda { |r, p| (Integer(r.conduct) & 4095).to_s(2).count("1") } # count the number of bits set in conduct
    property :conductX,  Text
    property :role,      String
    property :deathdnum, Integer
    property :gender,    String
    property :gender0,   String
    property :uid,       Integer
    property :maxhp,     Integer
    property :points,    Integer
    property :deathdate, String
    property :version,   String
    property :old_version, String
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
    property :user_seed,  String
    property :seed,       String

    property :xplevel, Integer, :default => 0
    property :exp,     Integer, :default => 0
    property :mode,    String
    property :gold,    Integer, :default => -1
    property :killed_uniques, Text
    property :killed_nazgul, Integer, default: 0
    property :killed_erinyes, Integer, default: 0
    property :killed_weeping_archangels, Integer, default: 0
    property :killed_archangels, Integer, default: 0
    property :wish_cnt,       Integer, default: -1
    property :magic_wish_cnt, Integer, default: -1
    property :arti_wish_cnt,  Integer, default: -1
    property :bones,          Integer, default: -1

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

    # dnethack and variants specific properties
    property :dnetachieve, String
    property :inherited, String
    property :species, String
    property :species0, String

    # nh4k-specific properties
    property :variant, String
    property :versionstring, String

    # fiqhack-specific properties
    property :name64,     String
    property :charname64, String
    property :death64,    String
    property :dumplog64,  String

    # SlashTHEM/SlashEm Extended-specific properties
    property :modes, String
    property :hybrid, String
    property :gamemode, String
    property :achieveX, Text
    property :alias, String
    property :role0, String
    property :race0, String

    # xnethack-specific properties
    property :polyinit, String

    # new in 3.6.0
    property :while, String

    property :difficulty, String
    property :demo, String

    # fourk specific properties
    property :gameidnum, Integer
    property :gengold, String

    # gnollhack specific properties
    property :scoring, String
    property :edit, String
    property :cname, String
    property :collapse, String
    property :tournament, String
    property :starttimeUTC, Integer
    property :endtimeUTC, Integer
    property :platform, String
    property :platformversion, String
    property :port, String
    property :portversion, String
    property :portbuild, String

    property :killed_medusa, Integer
end
