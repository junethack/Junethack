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
      case hostname
      when "un.nethack.nu"
        tld = (@name == "eun") ? "eu" : "us"
        return "https://un.nethack.nu/user/#{game.name}/dumps/#{tld}/#{game.name}.#{game.endtime}.txt.html"
      when "nethack.alt.org"
        return "http://alt.org/nethack/userdata/#{game.name[0..0]}/#{game.name}/dumplog/#{game.starttime}.nh343.txt"
      when "grunthack.org"
        return "http://grunthack.org/userdata/#{game.name[0..0]}/#{game.name}/dumplog/#{game.starttime}.gh020.txt"
      when "nethack.xd.cm"
        case game.version
        when "3.4.3"
            return "https://nethack.xd.cm/userdata/#{game.name}/nethack/dumplog/#{game.starttime}"
        when "DNH"
            return "https://nethack.xd.cm/userdata/#{game.name}/dnethack/dumplog/#{game.starttime}"
        when "3.0.1"
            return "https://nethack.xd.cm/userdata/#{game.name}/nh4k/4.3.0.1/dumps/#{game.dumplog.tr("_",":")}"
        when "0.6.3"
            return "https://nethack.xd.cm/userdata/#{game.name}/sporkhack/dumplog/#{game.starttime}"
        when "NH-1.3d"
            return "https://nethack.xd.cm/userdata/#{game.name}/oldhack/dumplog/#{game.starttime}"
        when "slth"
            return "https://nethack.xd.cm/userdata/#{game.name}/slashthem/dumplog/#{game.starttime}"
        end
      else
        return nil
      end
    end
end

DataMapper::MigrationRunner.migration( 1, :create_servers ) do
  up do
    Server.create name: 'nao', variant: 'NetHack 3.4.3-NAO', url: 'https://nethack.alt.org/', xlogurl: 'http://alt.org/nethack/xlogfile.full.txt', configfileurl: 'http://alt.org/nethack/userdata/random_user/random_user.nh343rc'
    Server.create name: 'eun', variant: 'UnNetHack 5.3.0', url: 'https://un.nethack.nu/', xlogurl: 'https://un.nethack.nu/logs/xlogfile-eu', configfileurl: 'https://un.nethack.nu/rcfiles/random_user.nethackrc'
    #Server.create name: 'shc', variant: 'sporkhack', url: 'sporkhack.com', xlogurl: 'http://sporkhack.com/xlogfile', configfileurl: 'http://sporkhack.com/rcfiles/random_user.nethackrc'
    Server.create name: 'gho', variant: 'GruntHack 0.2.0', url: 'http://grunthack.org/', xlogurl: 'http://grunthack.org/xlogfile', configfileurl: 'http://grunthack.org/userdata/random_user/random_user.gh020rc'
    Server.create name: 'nh4', variant: 'NetHack4 4.3.0', url: 'http://nethack4.org/', xlogurl: 'http://nethack4.org/xlogfile.txt', configfileurl: 'http://nethack4.org/junethack-rc/random_user.rc'
    Server.create name: 'nxc_nao', variant: 'NetHack 3.4.3-NAO', url: 'https://nethack.xd.cm/', xlogurl: 'https://nethack.xd.cm/xlogfiles/nethack', configfileurl: 'https://nethack.xd.cm/userdata/random_user/nethack/nethackrc'
    Server.create name: 'nxc_dnh', variant: 'dNetHack 3.9.1', url: 'https://nethack.xd.cm/', xlogurl: 'https://nethack.xd.cm/xlogfiles/dnethack', configfileurl: 'https://nethack.xd.cm/userdata/random_user/nethack/nethackrc'
    Server.create name: 'nxc_nh4k', variant: 'NetHack Fourk 4.3.0.1', url: 'https://nethack.xd.cm/', xlogurl: 'https://nethack.xd.cm/xlogfiles/nh4k', configfileurl: 'https://nethack.xd.cm/userdata/random_user/nethack/nethackrc'
    Server.create name: 'nxc_slth', variant: "SlashTHEM 0.7.0", url: 'https://nethack.xd.cm/', xlogurl: 'https://nethack.xd.cm/xlogfiles/slashthem', configfileurl: 'https://nethack.xd.cm/userdata/random_user/nethack/nethackrc'
    Server.create name: 'nxc_shc', variant: 'SporkHack 0.6.3', url: 'https://nethack.xd.cm/', xlogurl: 'https://nethack.xd.cm/xlogfiles/sporkhack', configfileurl: 'https://nethack.xd.cm/userdata/random_user/nethack/nethackrc'
    Server.create name: 'nxc_n13', variant: "NetHack 1.3d", url: 'https://nethack.xd.cm/', xlogurl: 'https://nethack.xd.cm/xlogfiles/oldhack', configfileurl: 'https://nethack.xd.cm/userdata/random_user/nethack/nethackrc'
  end
  down do
    Server.destroy
  end
end


DataMapper::MigrationRunner.migration( 2, :update_dnethack_name ) do
  up do
    execute "update servers set variant = 'dNetHack 3.9.3' where name = 'nxc_dnh'"
  end
end
