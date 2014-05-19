require 'dm-migrations'
require 'dm-migrations/migration_runner'

require 'open-uri'

class Server
    include DataMapper::Resource

    has n, :games
    has n, :accounts
    has n, :users, :through => :accounts

    property :id,                Serial
    property :name,              String, :length => 255
    property :url,               String, :length => 255
    property :xlogurl,           String, :length => 255
    property :xloglastmodified,  String, :default => "Sat Jan 01 00:00:00 UTC 2000"
    property :variant,           String
    property :xlogcurrentoffset, Integer
    property :configfileurl,     String, :length => 255

    # open the rc file for the user and return true if the regexp is found
    def verify_user(user, regexp)
        open(configfileurl.gsub("random_user", CGI::escape(user))) do |f|
            f.each do |line|
              return true if line.strip.match regexp
            end
        end
        return false;
    end

    def display_name
        url+" ("+variant+")"
    end

    def dumplog_link(game)
      case @url
      when "un.nethack.nu"
        return "http://un.nethack.nu/user/#{game.name}/dumps/#{game.name}.#{game.endtime}.txt.html"
      when "nethack.alt.org"
        return "http://alt.org/nethack/userdata/#{game.name[0..0]}/#{game.name}/dumplog/#{game.starttime}.nh343.txt"
      when "grunthack.org"
        return "http://grunthack.org/userdata/#{game.name[0..0]}/#{game.name}/dumplog/#{game.starttime}.gh020.txt"
      when "acehack.de"
        if game.version == '3.4.3' then
          return "http://acehack.de/userdata/#{game.name}/nethack/dumplog/#{game.starttime}"
        else
          return "http://acehack.de/userdata/#{game.name}/dumplog/#{game.starttime}"
        end
      else
        return nil
      end
    end
end

DataMapper::MigrationRunner.migration( 1, :create_servers ) do
  up do
    Server.create :name => 'nao', :variant => 'vanilla', :url => 'nethack.alt.org', :xlogurl => 'http://alt.org/nethack/xlogfile.full.txt', :configfileurl => 'http://alt.org/nethack/userdata/random_user/random_user.nh343rc'
    Server.create :name => 'eun', :variant => 'unnethack', :url => 'un.nethack.nu', :xlogurl => 'http://un.nethack.nu/logs/xlogfile', :configfileurl => 'http://un.nethack.nu/rcfiles/random_user.nethackrc'
    Server.create :name => 'shc', :variant => 'sporkhack', :url => 'sporkhack.com', :xlogurl => 'http://sporkhack.com/xlogfile', :configfileurl => 'http://sporkhack.com/rcfiles/random_user.nethackrc'
    #Server.create :name => 'neu', :variant => 'vanilla', :url => 'nethack.eu', :xlogurl => 'file:///home/junethack/neu/xlogfile', :configfileurl => 'http://nethack.eu:8000/junethack/raw-file/tip/rcfiles/random_user.nh343rc'
    Server.create :name => 'gho', :variant => 'grunthack', :url => 'grunthack.org', :xlogurl => 'http://grunthack.org/xlogfile', :configfileurl => 'http://grunthack.org/userdata/random_user/random_user.gh020rc'
    Server.create :name => 'nh4', :variant => 'nethack4', :url => 'nethack4.org', :xlogurl => 'http://nethack4.org/xlogfile.txt', :configfileurl => 'http://nethack4.org/junethack-rc/random_user.rc'
    Server.create :name => 'ade', :variant => 'acehack', :url => 'acehack.de', :xlogurl => 'http://acehack.de/xlogfile', :configfileurl => 'http://acehack.de/userdata/random_user/acehackrc'
  end
  down do
    Server.destroy
  end
end

DataMapper::MigrationRunner.migration( 2, :add_naohack_acehack_de ) do
  up do
    Server.create :name => 'nde', :variant => 'vanilla', :url => 'acehack.de', :xlogurl => 'http://acehack.de/nethackxlogfile', :configfileurl => 'http://acehack.de/userdata/random_user/nethack/nethackrc'
  end
  down do
    Server.all(:name => "nde").destroy
  end
end
