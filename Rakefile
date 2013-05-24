require 'rubygems'
require "bundler/setup"

require 'date'

require './lib/junethack'
require 'trophyscore'
require 'normalize_death'

require 'sync'
require 'rake/dsl_definition'
require 'rake'

$db_access = Sync.new

load File.expand_path('spec/spec.rake')

# default database is development
ENV['RACK_ENV'] = "production" unless ENV['RACK_ENV']
require 'database'

namespace :update do
    i = 0
    desc "recalculate scores"
    task :scores do
        (repository.adapter.select "select version,id,ascended from games where user_id is not null order by endtime").each {|game|
            i += 1
            puts "#{i} #{game.version}"
            update_scores(Game.get(game.id))
        }
    end

    desc "recalculate competition scores"
    task :user_competition do
        (repository.adapter.select "select version,id,ascended from games where user_id is not null and ascended='t' order by endtime").each {|game|
            i += 1
            puts "#{i} #{game.version}"
            update_competition_scores_ascended(Game.get(game.id))
        }
    end

    # only update nconducts field
    task :nconducts do
        i = 0
        Game.all.each do |game|
            game.nconducts = (Integer game.conduct).to_s(2).count("1")
            i += 1
            puts i
            game.save! # only change field and don't call hooks
        end
    end

    desc "recalculate clan scores"
    task :clan_winner do
        rank_clans
        score_clans
    end

    task :normalize_deaths do
        (repository.adapter.select "select version,id,ascended from games where user_id is not null order by endtime").each {|game|
            i += 1
            puts "#{i} #{game.version}"
            normalize_death(Game.get(game.id))
        }
    end

    task :all_stuff do
        (repository.adapter.select "select version,id,ascended from games where user_id is not null and ascended='t' order by endtime").each {|game|
            i += 1
            puts "#{i} #{game.version}"
            update_all_stuff(Game.get(game.id))
        }
    end
end

namespace :db do
    desc "fetch new xlogfile entries from game servers"
    task :get_games do
        require 'fetch_games'
        fetch_all
    end

    # Create registered users by using player names.
    # Combine players on different servers by the common name.
    task :create_users_heuristically do
        (repository.adapter.select "select distinct name,server_id from games where user_id is null").each {|u|
            name = u['name']
            server = Server.get(u['server_id'])
            puts "#{name}, #{server.name}"
            user = User.first_or_create(:login => name)
            account = Account.first_or_create(:user => user, :server => server, :name => name, :verified => true)
            Game.all(:name => name, :server => server).update(:user_id => user.id) if account
            repository.adapter.execute "UPDATE start_scummed_games set user_id = ? where name = ? and server_id = ?", user.id, name, server.id
        }
    end

    desc "start irb with database connected"
    task :irb do
        require 'irb'
        ARGV.clear
        IRB.start
    end

    desc "add a server"
    task :add_server, :name, :variant, :url, :xlogurl, :configfileurl do |t, args|
        puts "add server got #{args.inspect}"
        Server.create(:name => args[:name], :variant => args[:variant], :url => args[:url], :xlogurl => args[:xlogurl], :configfileurl => args[:configfileurl])
        Trophy.check_trophies_for_variant args[:variant]
    end
end

namespace :news do

    desc "add a new news entry"
    task :add, :html_snippet do |t, args|
        news = News.new
        news.html = args[:html_snippet]
        news.save
    end

    desc "delete a new news entry"
    task :delete, :id do |t, args|
        news = News.get(args[:id]).destroy
    end

    desc "update a new news entry"
    task :update, :id, :html_snippet do |t, args|
        news = News.get(args[:id])
        news.html = args[:html_snippet]
        news.save
    end

    desc "list all news entries"
    task :list do |t, args|
        news = News.all(:order => [ :id.desc ])
        news.each {|n| puts n.inspect}
    end
end

namespace :run do
    desc "start maintenance mode"
    task :maintenance  do
        require 'maintenance'
        Sinatra::Application.run!
    end

    desc "start server"
    task :server do
        require 'sinatra_server'
        Sinatra::Application.run!
    end
end

task :default => ["run:server"]

