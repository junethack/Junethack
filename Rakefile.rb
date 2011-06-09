require 'rubygems'
require 'database'
require 'fetch_games'
require 'date'

namespace :bogus do

	names = ["r4wrmage","ad3on","k3rio","bh44k","c4smith789", "st3nno"]	#hi #junethack
	task :init do
		Rake::Task['bogus:add_servers'].invoke
		for name in names
			puts "creating user and account #{name}"
			Rake::Task['bogus:add_user'].invoke(name)
			Rake::Task['bogus:add_user'].reenable
		end
		Rake::Task['bogus:add_game'].invoke 20
	end

	task :add_server :name, :url, :xlogurl do |t, args|
		Server.create(:name => args[:name], :url => args[:url], :xlogurl => args[:xlogurl]
						
	task :add_servers do
		Server.create(:name => "test server 1", :url => "localhost", :xlogurl => "file://test_xlog.txt", :xloglastmodified => "1.1.1970", :xlogcurrentoffset => 0)
		Server.create(:name => "test server 2", :url => "localhost", :xlogurl => "file://test_xlog2.txt", :xloglastmodified => "1.1.1970", :xlogcurrentoffset => 0)

	end


	task :add_user, :name do |t, args|
		
		puts "args were: #{args.inspect}"
		raise "No user name specified" unless args[:name]
		user = User.new(:name => args[:name], :login => args[:name])
		user.password = args[:name]
		user.save
		
		acc = Account.create(:user => user, :server => Server.get(1), :name => args[:name], :verified => true)
		
		puts "Account created: #{acc.inspect}"

		acc2 = Account.create(:user => user, :server => Server.get(2), :name => args[:name], :verified => true)
	end

	task :add_game, :games do |t, args|
		
		deaths = [		#some deaths, feel free to add more :P
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
			"ascended"
		]
		args.with_defaults(:games => 1)
		args[:games].to_i.times do
			gender = ["Fem", "Mal"][rand 2]
			align = ["Law","Neu","Cha"][rand 3]
			death = deaths[rand 11]
			game = {
				:name => names[rand 6],
				:deaths => rand(3),
				:deathlev => rand(30) + 1,
				:realtime => rand(10000) + 10000,
				:turns => rand(1000) + 200,
				:birthdate => (Time.now - 100000).strftime("%Y%m%d"),
				:conduct => rand(4096),		#some bitmask (wrong)
				:nconducts => rand(12),		#as of now, does not match with the 'conduct' property
				:role => ["Arc", "Bar", "Cav", "Hea", "Kni", "Mon", "Pri", "Ran", "Rog", "Sam", "Tou", "Val", "Wiz"][rand 13],
				:deathdnum => rand(57) - 5,
				:gender => gender,
				:gender0 => gender,
				:uid => 5,		#dunno what that does
				:maxhp => rand(250) + 10,
				:points => rand(350000),
				:deathdate => (Time.now - 50000).strftime("%Y%m%d"),
				:version => "3.4.3",
				:align => align,
				:align0 => align,
				:starttime => Time.now.to_i - 100000, #too lazy for realistic values...
				:endtime => Time.now.to_i - 50000,
				:achieve => rand(4096),			#wrong here, too lazy
				:hp => death == "ascended" ? rand(250) + 10 : rand(10) - 10,
				:maxlvl => rand(57),
				:death => death,
				:race => ["Dwa", "Hum", "Gno", "Elf"][rand 4],
				:flags => nil		#dunno what that does
			}
			sh "echo \"#{game.to_xlog}\" >> #{["test_xlog.txt", "test_xlog2.txt"][rand 2]}"
		end
	end
end

namespace :fetch do
	task :get_games do
		fetch_all
	end
end
