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
        hostname+" ("+variant+")"
    end

    def hostname
      @host ||= URI(url).host
    end

    def dumplog_link(game)
      case @url
      when "un.nethack.nu"
        tld = (@name == "eun") ? "eu" : "us"
        return "https://un.nethack.nu/user/#{game.name}/dumps/#{tld}/#{game.name}.#{game.endtime}.txt.html"
      when "nethack.alt.org"
        return "http://alt.org/nethack/userdata/#{game.name[0..0]}/#{game.name}/dumplog/#{game.starttime}.nh343.txt"
      when "grunthack.org"
        return "http://grunthack.org/userdata/#{game.name[0..0]}/#{game.name}/dumplog/#{game.starttime}.gh020.txt"
      when "acehack.de"
        case game.version
        when '3.4.3'
          return "http://acehack.de/userdata/#{game.name}/nethack/dumplog/#{game.starttime}"
        when 'NH-1.3d'
          return "http://acehack.de/userdata/#{game.name}/oldhack/dumplog/#{game.starttime}"
        else
          return "http://acehack.de/userdata/#{game.name}/dumplog/#{game.starttime}"
        end
      when "dnethack.ilbelkyr.de"
        return "http://dnethack.ilbelkyr.de/userdata/#{game.name}/dumplog/#{game.starttime}.dnao.txt"
      else
        return nil
      end
    end
end

DataMapper::MigrationRunner.migration( 1, :create_servers ) do
  up do
    Server.create name: 'nao', variant: 'NetHack 3.4.3-NAO', url: 'https://nethack.alt.org/', xlogurl: 'http://alt.org/nethack/xlogfile.full.txt', configfileurl: 'http://alt.org/nethack/userdata/random_user/random_user.nh343rc'
    Server.create name: 'eun', variant: 'UnNetHack 5.3.0', url: 'https://un.nethack.nu/', xlogurl: 'https://un.nethack.nu/logs/xlogfile-eu', configfileurl: 'https://un.nethack.nu/rcfiles/random_user.nethackrc'
    Server.create name: 'uun', variant: 'UnNetHack 5.3.0', url: 'https://un.nethack.nu/', xlogurl: 'https://un.nethack.nu/logs/xlogfile-us', configfileurl: 'https://un.nethack.nu/rcfiles/random_user.nethackrc'
    #Server.create name: 'shc', variant: 'sporkhack', url: 'sporkhack.com', xlogurl: 'http://sporkhack.com/xlogfile', configfileurl: 'http://sporkhack.com/rcfiles/random_user.nethackrc'
    Server.create name: 'gho', variant: 'GruntHack 0.2.0', url: 'http://grunthack.org/', xlogurl: 'http://grunthack.org/xlogfile', configfileurl: 'http://grunthack.org/userdata/random_user/random_user.gh020rc'
    Server.create name: 'nh4', variant: 'NetHack4 4.3.0', url: 'http://nethack4.org/', xlogurl: 'http://nethack4.org/xlogfile.txt', configfileurl: 'http://nethack4.org/junethack-rc/random_user.rc'
  end
  down do
    Server.destroy
  end
end

DataMapper::MigrationRunner.migration( 2, :nethack_xd_cm_server ) do
  up do
      Server.create name: 'nxc_nao', variant: 'NetHack 3.4.3-NAO', url: 'https://nethack.xd.cm/', xlogurl: 'https://nethack.xd.cm/xlogfiles/nethack', configfileurl: 'https://nethack.xd.cm/userdata/random_user/nethack/nethackrc'
      Server.create name: 'nxc_dnh', variant: 'dNetHack 3.9.1', url: 'https://nethack.xd.cm/', xlogurl: 'https://nethack.xd.cm/xlogfiles/dnethack', configfileurl: 'https://nethack.xd.cm/userdata/random_user/nethack/nethackrc'
      Server.create name: 'nxc_nh4k', variant: 'NetHack Fourk 4.3.0.1', url: 'https://nethack.xd.cm/', xlogurl: 'https://nethack.xd.cm/xlogfiles/nh4k', configfileurl: 'https://nethack.xd.cm/userdata/random_user/nethack/nethackrc'
  end
  down do
    Server.destroy
  end
end

DataMapper::MigrationRunner.migration( 3, :update_urls_public_server ) do
  up do
    execute "UPDATE servers set url='http://'||url where url not like 'http%'"
  end
  down do
    Server.destroy
  end
end
