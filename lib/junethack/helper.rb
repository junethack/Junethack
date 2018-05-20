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
$variants_mapping["3.4.3"]   = "NetHack 3.4.3"
$variants_mapping["3.6"]     = "NetHack 3.6.1"
$variants_mapping["shc"]     = "SporkHack"
$variants_mapping["unh"]     = "UnNetHack"
$variants_mapping["gho"]     = "GruntHack"
$variants_mapping["nh4"]     = "NetHack4"
$variants_mapping["dnh"]     = "dNetHack"
$variants_mapping["nh4k"]    = "NetHack Fourk"
$variants_mapping["fiq"]     = "FIQHack"
$variants_mapping["dyn"]     = "DynaHack"
$variants_mapping["slex"]    = "Slash'EM Extended"
$variants_mapping["spl"]     = "SpliceHack"
$variants_mapping["xnh"]     = "xNetHack"
$variants_mapping["NH-1.3d"] = "NetHack 1.3d"

# hard coded ordering of variants with competition score entries
# order by release date
$variant_order = []
$variant_order << "3.4.3"
$variant_order << "3.6"
$variant_order << "shc"
$variant_order << "unh"
$variant_order << "gho"
$variant_order << "dnh"
$variant_order << "nh4"
$variant_order << "nh4k"
$variant_order << "fiq"
$variant_order << "dyn"
#$variant_order << "slth"
$variant_order << "slex"
$variant_order << "xnh"
$variant_order << "spl"

def helper_get_variant_for(description)
    # hard coded descriptions for some variants
    return '3.4.3' if description.downcase == 'vanilla'
    return '3.6' if description.downcase == '3.6.0'
    return '3.6' if description.downcase == '3.6.1'
    return 'NH-1.3d' if description.downcase == 'oldhack'

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

