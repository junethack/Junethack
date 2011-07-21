require 'rubygems'
require "bundler/setup"
require 'database'
require 'fetch_games'
require 'date'
require 'trophyscore'

namespace :bogus do

    names = %w(r4wrmage ad3on k3rio bh44k c4smith789 st3nno)    #hi #junethack
    task :init do
      User.transaction do
        Rake::Task['bogus:add_servers'].invoke
        for name in names
            puts "creating user and account #{name}"
            Rake::Task['bogus:add_user'].invoke(name)
            Rake::Task['bogus:add_user'].reenable
        end
        Rake::Task['bogus:add_game'].invoke 20
      end
    end

    task :add_server, :name, :variant, :url, :xlogurl, :configfileurl do |t, args|
        puts "add server got #{args.inspect}"
        Server.create(:name => args[:name], :variant => args[:variant], :url => args[:url], :xlogurl => args[:xlogurl], :configfileurl => args[:configfileurl])
    end
    task :add_servers do
        Server.create(:name => "test server 1", :url => "localhost", :xlogurl => "file://test_xlog.txt", :xloglastmodified => "1.1.1970", :xlogcurrentoffset => 0, :configfileurl => "text_xlog_random_user.rc")
        Server.create(:name => "test server 2", :url => "localhost", :xlogurl => "file://test_xlog2.txt", :xloglastmodified => "1.1.1970", :xlogcurrentoffset => 0, :configfileurl => "text_xlog2_random_user.rc")
	puts "added #{ Server.all.length } test servers"
    end


    task :add_user, :name, :servername do |t, args|
        
        puts "args were: #{args.inspect}"
        raise "No user name specified" unless args[:name]
        user = User.new(:login => args[:name])
        user.password = args[:name]
        user.save
        if args[:servername]
            acc = Account.create(:user => user, :server => Server.get(:name => args[:servername]), :name => args[:name], :verified => true)
        else
            acc = Account.create(:user => user, :server => Server.get(1), :name => args[:name], :verified => true)
            acc2 = Account.create(:user => user, :server => Server.get(2), :name => args[:name], :verified => true)
        end
    end

    task :add_a_lot_of_games do
        Rake::Task['bogus:add_game'].invoke 500
    end

    task :add_game, :games do |t, args|
        
        deaths = [        #some deaths, feel free to add more :P #done -nooodl
            "killed by a newt",
            "petrified by a chickatrice corpse",
            "killed by a soldier ant",
            "killed by a mumak",
            "killed by a minotaur",
            "killed by a hallucinogen-distorted woodchuck",
            "drowned in a moat by a giant eel",
            "killed by brainlessness",
            "killed by Vlad the Impaler, while helpless",
            "killed by the Wizard of Yendor",
            "killed by self-genocide",
            "killed by overexertion",
            "died of starvation",
            "killed by a touch of death",
            "poisoned by Pestilence",
            "killed by a death ray",
            "escaped",
            "dissolved in molten lava",
            "killed by an Archon",
            "killed by Master Kaen",
            "ascended",
        ]
        args.with_defaults(:games => 1)
        xlog1 = File.open "test_xlog.txt", "a"
        xlog2 = File.open "test_xlog2.txt", "a"
        args[:games].to_i.times do
            gender = ["Fem", "Mal"][rand 2]
            align = ["Law","Neu","Cha"][rand 3]
            death = deaths[rand 21]
            game = {
                :name => names[rand 6],
                :deaths => rand(3),
                :deathlev => rand(30) + 1,
                :realtime => rand(10000) + 10000,
                :turns => rand(1000) + 200,
                :birthdate => (Time.now - 100000).strftime("%Y%m%d"),
                :conduct => rand(4096),        #some bitmask (wrong)
                :nconducts => rand(12),        #as of now, does not match with the 'conduct' property
                :role => %w(Arc Bar Cav Hea Kni Mon Pri Ran Rog Sam Tou Val Wiz)[rand 13],
                :deathdnum => rand(57) - 5,
                :gender => gender,
                :gender0 => gender,
                :uid => 5,        #dunno what that does
                :maxhp => rand(250) + 10,
                :points => rand(350000),
                :deathdate => (Time.now - 50000).strftime("%Y%m%d"),
                :version => "3.4.3",
                :align => align,
                :align0 => align,
                :starttime => Time.now.to_i - 100000, #too lazy for realistic values...
                :endtime => Time.now.to_i - 50000,
                :achieve => rand(4096),            #wrong here, too lazy
                :hp => death == "ascended" ? rand(250) + 10 : rand(10) - 10,
                :maxlvl => rand(57),
                :death => death,
                :race => %w(Dwa Hum Gno Elf)[rand 4],
                :flags => nil        #dunno what that does
            }
            [xlog1, xlog2][rand 2].puts game.to_xlog
        end
        xlog1.close
        xlog2.close
    end

    task :test_account_verification, :server_id, :user do |t, args|
        server = Server.get(args[:server_id])
        raise "verification failed for #{args[:user]} on server #{server.name}" unless server.verify_user(args[:user], Regexp.new("junethack2011 testuser"))
    end
end

namespace :fetch do
    task :get_games do
        fetch_all
    end
end

namespace :update do
    i = 0
    task :scores do
        (repository.adapter.select "select version,id,ascended from games where user_id is not null order by endtime").each {|game|
            i += 1
            puts "#{i} #{game.version}"
            update_scores(Game.get(game.id))
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
end
