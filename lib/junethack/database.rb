require 'rubygems'
require 'active_record'
require 'composite_primary_keys'
require 'ostruct'
require 'sinatra'
require 'sinatra/activerecord'

set :database_file, File.expand_path('../../../config/database.yml', __FILE__)

ActiveRecord.schema_format = :sql

Dir.mkdir('logs') unless File.exist?('logs')

configure :production do
  puts "Configuring production database"
  ActiveRecord.dump_schema_after_migration = false
end

configure :development do
  puts "Configuring development database"
  ActiveRecord::Base.logger = Logger.new("logs/dev_db.log")
end

configure :test do
  puts "Configuring test database"
  ActiveRecord::Base.logger = Logger.new("logs/test_db.log")
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
require 'queries/activity_queries'
