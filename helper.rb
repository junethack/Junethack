require 'orderedhash'

$variants_mapping = OrderedHash.new
$variants_mapping["3.4.3"]     = "NetHack 3.4.3"
$variants_mapping["UNH-3.5.4"] = "UnNetHack"
$variants_mapping["3.6.0"]     = "AceHack"
$variants_mapping["0.6.3"]     = "SporkHack"
$variants_mapping["NH-1.3d"]   = "NetHack 1.3d"

def helper_get_variants_for_user(id)
    variants = repository.adapter.select "select distinct version from games where user_id = ?;", @id
    v = $variants_mapping.dup.delete_if {|key,value| not variants.include? key }

    puts $variants_mapping.inspect
    puts v.inspect
    v
end
