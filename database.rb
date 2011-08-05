require 'rubygems'
require 'data_mapper'
require 'dm-serializer'
require 'dm-timestamps'

$dbname = "junethack.db"

# for debugging: print all generated SQL statemtens
#DataMapper::Logger.new("logs/db.log", :debug)

# raise exception on error when saving
DataMapper::Model.raise_on_save_failure = true # globally

# set all String properties to have a default length of 255
DataMapper::Property::String.length(255)


DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/#{$dbname}")

require 'models/server'
require 'models/user'
require 'models/account'
require 'models/game'
require 'models/startscummedgame'
require 'models/clan'
require 'models/scoreentry'
require 'models/trophy'

DataMapper.finalize
DataMapper.auto_upgrade!
DataMapper::MigrationRunner.migrate_up!
