require 'date'
require 'time'

$tournament_starttime       = Time.parse("2025-06-01 00:00:00Z").to_i
$tournament_endtime         = Time.parse("2025-07-01 00:00:00Z").to_i
# Monday before Junethack starts
# $tournament_signupstarttime = Time.parse("2025-05-26 00:00:00Z").to_i
$tournament_year = Time.at($tournament_starttime).year
