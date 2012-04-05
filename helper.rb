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
$variants_mapping["UNH-4.0.0"] = "UnNetHack"
$variants_mapping["3.6.0"]     = "AceHack"
$variants_mapping["0.6.3"]     = "SporkHack"
$variants_mapping["0.2.0"]     = "GruntHack"

# hard coded ordering of variants with competition score entries
# order by release date
$variants = []
$variants << "3.4.3"
$variants << "0.6.3"
$variants << "UNH-4.0.0"
$variants << "3.6.0"
$variants << "0.2.0"

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

