require 'rubygems'
require 'data_mapper'
require 'dm-serializer'
require 'dm-timestamps'
require 'dm-validations'
require 'sinatra'

# raise exception on error when saving
DataMapper::Model.raise_on_save_failure = true # globally

# set all String properties to have a default length of 255
DataMapper::Property::String.length(255)

USER = ENV['POSTGRES_USER'] || 'junethack'
PASSWORD = ENV['POSTGRES_PASSWORD'] || 'test'
HOST = ENV['POSTGRES_HOST'] || 'localhost'

configure :production do
  puts "Configuring production database"
  DATABASE = ENV['POSTGRES_DATABASE'] || 'junethack_production'
  # for debugging: print all generated SQL statemtens
  #DataMapper::Logger.new("logs/db.log", :debug)
  DataMapper.setup(:default, "postgres://#{USER}:#{PASSWORD}@#{HOST}/#{DATABASE}")
end

configure :development do
  puts "Configuring development database"
  DATABASE = ENV['POSTGRES_DATABASE'] || 'junethack_developmnet'
  # for debugging: print all generated SQL statemtens
  DataMapper::Logger.new("logs/dev_db.log", :debug)
  DataMapper.setup(:default, "postgres://#{USER}:#{PASSWORD}@#{HOST}/#{DATABASE}")
end

configure :test do
  puts "Configuring test database"
  DATABASE = ENV['POSTGRES_DATABASE'] || 'junethack_text'
  DataMapper::Logger.new("logs/test_db.log", :debug)
  DataMapper.setup(:default, "postgres://#{USER}:#{PASSWORD}@#{HOST}/#{DATABASE}")

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
