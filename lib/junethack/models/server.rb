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
      when "nethack.dank.ninja"
        case game.version
        when "3.4.3"
            return "https://nethack.dank.ninja/userdata/#{game.name}/nethack/dumplog/#{game.starttime}"
        when "DNH"
            return "https://nethack.dank.ninja/userdata/#{game.name}/dnethack/dumplog/#{game.starttime}"
        when "3.0.1"
            return "https://nethack.dank.ninja/userdata/#{game.name}/nhfourk/dumplog/#{game.dumplog.tr("_",":")}"
        when "0.6.3"
            return "https://nethack.dank.ninja/userdata/#{game.name}/sporkhack/dumplog/#{game.starttime}"
        when "NH-1.3d"
            return "https://nethack.dank.ninja/userdata/#{game.name}/oldhack/dumplog/#{game.starttime}"
        when "slth"
            return "https://nethack.dank.ninja/userdata/#{game.name}/slashthem/dumplog/#{game.starttime}"
        when "0.2.0"
            return "https://nethack.dank.ninja/userdata/#{game.name}/grunthack/dumplog/#{game.starttime}"
        when "UNH"
            return "https://nethack.dank.ninja/userdata/#{game.name}/unnethack/dumplog/#{game.starttime}"
        end
      when "nethack4.org"
        return "http://nethack4.org/dumps/#{game.dumplog.tr("_",":")}"
      else
        return nil
      end
    end
end

DataMapper::MigrationRunner.migration( 1, :create_servers ) do
  up do
    Server.create name: 'nao', variant: 'NetHack 3.4.3-NAO',
      url: 'https://nethack.alt.org/', xlogurl: 'https://alt.org/nethack/xlogfile.full.txt', configfileurl: 'http://alt.org/nethack/userdata/random_user/random_user.nh343rc'
    Server.create name: 'nao_nh36', variant: 'NetHack 3.6.0',
      url: 'https://nethack.alt.org/', xlogurl: 'https://alt.org/nethack/xlogfile.nh360', configfileurl: 'http://alt.org/nethack/userdata/random_user/random_user.nh360rc'

    Server.create name: 'eun', variant: 'UnNetHack 5.3.1',
      url: 'https://un.nethack.nu/', xlogurl: 'https://un.nethack.nu/logs/xlogfile-eu', configfileurl: 'https://un.nethack.nu/rcfiles/random_user.nethackrc'

    Server.create name: 'nh4', variant: 'NetHack4 4.3.0',
      url: 'http://nethack4.org/', xlogurl: 'http://nethack4.org/xlogfile.txt', configfileurl: 'http://nethack4.org/junethack-rc/random_user.rc'

    Server.create name: 'gho', variant: 'GruntHack 0.2.0',
      url: 'http://grunthack.org/', xlogurl: 'http://grunthack.org/xlogfile', configfileurl: 'http://grunthack.org/userdata/random_user/random_user.gh020rc'

    Server.create name: 'esm_nh36', variant: "NetHack 3.6.0",
      url: 'https://em.slashem.me/', xlogurl: 'https://em.slashem.me/xlogfiles/nethack', configfileurl: 'https://em.slashem.me/userdata/random_user/nethack/random_user.nh360rc'
    Server.create name: 'esm_slex', variant: "SlashEMExtended 1.7.1",
      url: 'https://em.slashem.me/', xlogurl: 'https://em.slashem.me/xlogfiles/slex', configfileurl: 'https://em.slashem.me/userdata/random_user/slex/random_user.slexrc'

    Server.create name: 'ndn_nao', variant: 'NetHack 3.4.3-NAO',
      url: 'https://nethack.dank.ninja/', xlogurl: 'https://nethack.dank.ninja/xlogfiles/nethack', configfileurl: 'https://nethack.dank.ninja/userdata/random_user/nethack/nethackrc'
    Server.create name: 'ndn_unh', variant: 'UnNetHack 5.3.1',
      url: 'https://nethack.dank.ninja/', xlogurl: 'https://nethack.dank.ninja/xlogfiles/unnethack', configfileurl: 'https://nethack.dank.ninja/userdata/random_user/nethack/nethackrc'
    Server.create name: 'ndn_dnh', variant: 'dNetHack 3.12.3',
      url: 'https://nethack.dank.ninja/', xlogurl: 'https://nethack.dank.ninja/xlogfiles/dnethack', configfileurl: 'https://nethack.dank.ninja/userdata/random_user/nethack/nethackrc'
    Server.create name: 'ndn_dyn', variant: 'DynaHack 0.6.0',
      url: 'https://nethack.dank.ninja/', xlogurl: 'https://nethack.dank.ninja/xlogfiles/dynahack', configfileurl: 'https://nethack.dank.ninja/userdata/random_user/nethack/nethackrc'
    Server.create name: 'ndn_slth', variant: "SlashTHEM 0.8.0",
      url: 'https://nethack.dank.ninja/', xlogurl: 'https://nethack.dank.ninja/xlogfiles/slashthem', configfileurl: 'https://nethack.dank.ninja/userdata/random_user/nethack/nethackrc'
    Server.create name: 'ndn_nh4k', variant: 'NetHack Fourk 4.3.0.3',
      url: 'https://nethack.dank.ninja/', xlogurl: 'https://nethack.dank.ninja/xlogfiles/nhfourk', configfileurl: 'https://nethack.dank.ninja/userdata/random_user/nethack/nethackrc'
    Server.create name: 'ndn_fiq', variant: "FIQHack 4.3.0",
      url: 'https://nethack.dank.ninja/', xlogurl: 'https://nethack.dank.ninja/xlogfiles/fiqhack', configfileurl: 'https://nethack.dank.ninja/userdata/random_user/nethack/nethackrc'
  end
  down do
    Server.destroy
  end
end

DataMapper::MigrationRunner.migration( 2, :update_servers_1 ) do
  up do
    Server.create name: 'nao_nh361', variant: 'NetHack 3.6.1-dev',
      url: 'https://nethack.alt.org/', xlogurl: 'https://alt.org/nethack/xlogfile.nh361dev', configfileurl: 'http://alt.org/nethack/userdata/random_user/random_user.nh360rc'

    Server.create name: 'ndn_nh4', variant: 'NetHack4 4.3.0',
      url: 'https://nethack.dank.ninja/', xlogurl: 'https://nethack.dank.ninja/xlogfiles/nethack4', configfileurl: 'https://nethack.dank.ninja/userdata/random_user/nethack/nethackrc'
  end
end

DataMapper::MigrationRunner.migration( 3, :remove_slth ) do
  up do
    server = Server.first(name: 'ndn_slth')
    Account.all(server_id: server.id).destroy
    server.destroy
  end
end
