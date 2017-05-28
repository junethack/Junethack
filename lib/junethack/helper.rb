$trophies = [
 'most_ascensions',
 'longest_ascension_streaks',
 'fastest_ascension_gametime',
 'fastest_ascension_realtime',
 'highest_scoring_ascension',
 'lowest_scoring_ascension',
 'most_conducts_ascension',
]

$trophies_name = [
 "Most ascensions",
 "Longest ascension streak",
 "Fastest ascension (by turns)",
 "Fastest ascension (by wall-clock time)",
 "Highest scoring ascension",
 "Lowest scoring ascension",
 "Most conducts in a single ascension",
]

$variants_mapping = {}
$variants_mapping["3.4.3"]     = "NetHack 3.4.3"
$variants_mapping["3.6.0"]     = "NetHack 3.6.0"
$variants_mapping["0.6.3"]     = "SporkHack 0.6.3"
$variants_mapping["UNH"]       = "UnNetHack"
$variants_mapping["0.2.1"]     = "GruntHack"
$variants_mapping["4.3.0"]     = "NetHack4"
$variants_mapping["DNH"]       = "dNetHack"
$variants_mapping["3.0.4"]     = "NetHack Fourk"
$variants_mapping["fiqhack"]   = "FIQHack"
$variants_mapping["0.6.0"]     = "DynaHack"
#$variants_mapping["slth"]      = "SlashTHEM"
$variants_mapping["slex"]      = "Slash'EM Extended"

# hard coded ordering of variants with competition score entries
# order by release date
$variant_order = []
$variant_order << "3.4.3"
$variant_order << "3.6.0"
$variant_order << "0.6.3"
$variant_order << "UNH"
$variant_order << "0.2.1"
$variant_order << "DNH"
$variant_order << "4.3.0"
$variant_order << "3.0.4"
$variant_order << "fiqhack"
$variant_order << "0.6.0"
#$variant_order << "slth"
$variant_order << "slex"

def helper_get_variant_for(description)
    # hard coded descriptions for some variants
    return '3.4.3' if description.downcase == 'vanilla'
    return '3.6.0' if description.downcase == '3.6.0'
    return 'NH-1.3d' if description.downcase == 'oldhack'
    return '0.6.3' if description.downcase == 'sporkhack'

    # find variant by text description
    variant = $variants_mapping.find {|v,k| k.downcase == description.downcase}
    return variant[0] if variant
end

def helper_get_variants_for_user(id)
    variants = repository.adapter.select "select distinct version from games where user_id = ?;", @id
    v = $variants_mapping.dup.reject {|key,value| not variants.include? key }
end

def helper_get_score(key, variant)
    return repository.adapter.select "select (select login from users where user_id = id) as user, user_id, value, value_display from scoreentries where trophy = ? and variant = ? order by user;", key, variant
end

def parse_seconds(duration=nil)
    return "" if not duration
    s = duration;
    m = s / 60;
    h = m / 60;
    d = h / 24;
    str = []
    str << "#{d} d" if d>0
    str << "#{h % 24} h" if h>0
    str << "#{m % 60} m" if m>0
    str << "#{s % 60} s" if s>0
    return str.join " "
end

