require 'rubygems'
require 'data_mapper'
require 'dm-serializer'
$dbname = "junethack.db"

# for debugging: print all generated SQL statemtens
#DataMapper::Logger.new(STDOUT, :debug)

# raise exception on error when saving
DataMapper::Model.raise_on_save_failure = true # globally

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/#{$dbname}")

require 'models/server'
require 'models/user'
require 'models/account'
require 'models/game'
require 'models/clan'
require 'models/scoreentry'

DataMapper.finalize
DataMapper.auto_upgrade!
DataMapper::MigrationRunner.migrate_up!
