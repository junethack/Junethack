require 'rubygems'
require 'data_mapper'
require 'dm-serializer'
require 'dm-timestamps'
require 'sinatra'

# raise exception on error when saving
DataMapper::Model.raise_on_save_failure = true # globally

# set all String properties to have a default length of 255
DataMapper::Property::String.length(255)

configure :production do
  puts "Configuring production database"
  # for debugging: print all generated SQL statemtens
  #DataMapper::Logger.new("logs/db.log", :debug)
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/junethack.db")
end
configure :development do
  puts "Configuring development database"
  # for debugging: print all generated SQL statemtens
  DataMapper::Logger.new("logs/dev_db.log", :debug)
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/junethack_dev.db")
end
configure :test do
  puts "Configuring test database"
  DataMapper::Logger.new("logs/test_db.log", :debug)
  DataMapper.setup(:default, "sqlite3::memory:")

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
require 'models/junkgame'
require 'models/clan'
require 'models/scoreentry'
require 'models/trophy'
require 'models/event'
require 'models/news'

DataMapper.finalize
DataMapper.auto_upgrade!
DataMapper::MigrationRunner.migrate_up!
