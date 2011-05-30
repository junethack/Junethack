
$conducts = [
	[0x001, "Foodless", "Foo"],
	[0x002, "Vegan", "Vgn"],	
	[0x004, "Vegetarian", "Vgt"],
	[0x008, "Atheist", "Ath"],
	[0x010, "Weaponless", "Wea"],
	[0x020, "Pacifist", "Pac"],
	[0x040, "Illiterate", "Ill"],
	[0x080, "Polypileless", "Ppl"],
	[0x100, "Polyselfless", "Psf"],
	[0x200, "Wishless", "Wsh"],
	[0x400, "Artiwishless", "Art"],
	[0x800, "Genocideless", "Gen"]
]
class Game
        include DataMapper::Resource
        belongs_to :server

        property :id,           Serial
        property :name,         String
        property :deaths,       Integer
        property :deathlev,     Integer
        property :realtime,     Integer
        property :turns,        Integer
        property :birthdate,    String
        property :conduct,      Integer
	property :nconducts,	Integer
        property :role,         String
        property :deathdnum,    Integer
        property :gender,       String
	property :gender0,	String
        property :uid,          Integer
        property :maxhp,        Integer
        property :points,       Integer
        property :deathdate,    String
        property :version,      String
        property :align,        String
	property :align0,	String
        property :starttime,    String
	property :endtime,	String
        property :achieve,      Integer
	property :nachieves,	Integer
        property :hp,           Integer
        property :maxlvl,       Integer
        property :death,        String
        property :race,         String
	property :flags,	String
	def get_conducts
		$conducts.map{|c| self.conduct & c[0] == c[0] ? c[2] : ""}.join
	end
end
