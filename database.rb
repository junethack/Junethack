require 'rubygems'
require 'data_mapper'
require 'dm-serializer'
require 'dm-timestamps'
require 'sinatra'

$dbname = "junethack.db"

# for debugging: print all generated SQL statemtens
#DataMapper::Logger.new("logs/db.log", :debug)

# raise exception on error when saving
DataMapper::Model.raise_on_save_failure = true # globally

# set all String properties to have a default length of 255
DataMapper::Property::String.length(255)

options = {}
configure :production do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/#{$dbname}")
end
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/dev_#{$dbname}")
end
configure :test do
  DataMapper.setup(:default, "sqlite3::memory:")
  DataMapper::Logger.new("logs/test_db.log", :debug)

  # suppress migration output.
  # it would be written at every run as we use a in-memory db
  module DataMapper
    class Migration
      def write(text="")
      end
    end
  end
end

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
