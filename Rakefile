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
ENV['RACK_ENV'] = "development" unless ENV['RACK_ENV']
require 'database'

namespace :update do
    i = 0
    desc "recalculate scores"
    task :scores do
      (repository.adapter.select "select version,id,ascended from games where user_id is not null order by endtime").each {|game|
        i += 1
        puts "#{i} #{game.id} #{game.version}"
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
            game.nconducts = (Integer(game.conduct) & 4095).to_s(2).count("1")
            i += 1
            puts i
            game.save! # only change field and don't call hooks
        end
    end

    task :killed_medusa do
      i = 0
      Game.transaction do
        Game.all.each do |game|
          game.killed_medusa = game.defeated_medusa? ? 1 : 0
          i += 1
          puts i if i % 100 == 0
          game.save! # only change field and don't call hooks
        end
      end
    end

    desc "re-rank clans"
    task :clan_winner do
      rank_clans
      score_clans
    end

    desc "recalculate clan scores"
    task :clan_scores do
      Clan.all.each {|clan|
        puts clan.name
        game = Game.all(user_id: clan.users.map(&:id)).last
        update_clan_scores(game) if game
      }
    end

    task :normalize_deaths do
        (repository.adapter.select "select version,id,ascended from games where user_id is not null order by endtime").each {|game|
            i += 1
            puts "#{i} #{game.version}"
            local_normalize_death(Game.get(game.id))
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

    desc "reset a server's xlogfile modification date"
    task :reset_server, :name do |t, args|
        Server.all(name: args[:name]).update(xloglastmodified: "Sat Jan 01 00:00:00 UTC 2000",
                                             xlogcurrentoffset: 0)
        puts Server.all(name: args[:name]).inspect
    end
    desc "reset all servers' xlogfile modification date"
    task :reset_all_servers, :name do |t, args|
        Server.all.update(xloglastmodified: "Sat Jan 01 00:00:00 UTC 2000",
                                             xlogcurrentoffset: 0)
    end

    desc "change a user's password"
    task :change_password, :user, :password do |t, args|
        user = User.first(:login => args[:user])
        puts "User #{args[:user]} not found!" if not user
        puts "No password given!" if not args[:password]
        if user and args[:password] then
            user.password = args[:password]
            user.save
        end
    end

    desc "post-mortem statistics"
    task :statistics do
        puts "Some boring statistics:"
        puts
        puts "#{User.count} players registered on the server,"
        puts "#{User.all(:accounts.not => nil).count} linked their account with the public servers,"
        puts "and #{Game.all(:fields => [:user_id]).map {|g| g.user_id}.uniq.count} actually played at least one game."
        puts
        puts "#{Game.all(:user_id.not => nil).count} games were played on all #{Server.count} public servers during the tournament by registered users,"
        puts "#{Game.count} were played by all players including those not taking part in the tournament."
        puts
        games_ascended = Game.all(:conditions => [ "user_id is not null and ascended='t'" ])
        puts "#{games_ascended.collect {|g| g.user_id}.uniq.count} different players ascended a total of #{games_ascended.count} games."

        puts
        puts "Tournament games by variant"
        $variant_order.each do |v|
            puts "#{$variants_mapping[v]}: #{Game.all(:conditions => [ "user_id > 0 and version = '#{v}'" ]).count}"
        end
    end
end

namespace :news do

  desc "add a new news entry"
  task :add, :html_snippet, :url, :publish_at do |t, args|
    ARGV.each {|a| task a.to_sym do ; end }
    news = News.new
    news.html = args[:html_snippet] || ARGV[1]
    news.url = args[:url] || ARGV[2]
    if args[:publish_at] && !args[:publish_at].empty?
      news.updated_at = news.created_at = DateTime.parse(args[:publish_at])
    end
    news.save
  end

  desc "delete a new news entry"
  task :delete, :id do |t, args|
    News.get(args[:id]).destroy
  end

  desc "update a new news entry"
  task :update, :id, :html_snippet, :url do |t, args|
    ARGV.each {|a| task a.to_sym do ; end }
    news = News.get(args[:id])
    news.html = args[:html_snippet] || ARGV[1]
    news.url = args[:url] || ARGV[2]
    news.save
  end

  desc "list all news entries"
  task :list do |t, args|
    news = News.all order: [ :created_at.desc ]
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

        # write the current process id to a file
        File.open("junethack.pid", "w") {|f| f.puts(Process.pid) }
        Signal.trap(0, proc { File.delete "junethack.pid" })

        Sinatra::Application.run!
    end
end

namespace :test do
  desc 'Import a local xlogfile'
  task :import, :file, :server do |t, args|
    require 'parse'
    server = Server.first(name: args[:server])
    lines = File.open(args[:file]).readlines
    lines.each {|line|
      hgame = XLog.parse_xlog line.force_encoding(Encoding::UTF_8).encode("utf-8", invalid: :replace)
      game = Game.create({server: server}.merge(hgame))

      account = Account.first(name: hgame["name"], server_id: server.id)
      game.update(user_id: account.user_id) if account
    }
  end
end

task :default => ["run:server"]

