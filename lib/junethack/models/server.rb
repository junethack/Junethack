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
        case game.version
        when "3.4.3"
          return "http://alt.org/nethack/userdata/#{game.name[0..0]}/#{game.name}/dumplog/#{game.starttime}.nh343.txt"
        end
      when "grunthack.org"
        return "http://grunthack.org/userdata/#{game.name[0..0]}/#{game.name}/dumplog/#{game.starttime}.gh020.txt"
      when "nethack.dank.ninja", "ascension.run"
        case game.version
        when "3.4.3"
            return "https://ascension.run/userdata/#{game.name}/nethack/dumplog/#{game.starttime}"
        when "DNH"
            return "https://ascension.run/userdata/#{game.name}/dnethack/dumplog/#{game.starttime}"
        when "3.0.1", "3.0.3"
            return "https://ascension.run/userdata/#{game.name}/nhfourk/dumplog/#{game.dumplog.tr("_",":")}"
        when "4.3.0"
            return "https://ascension.run/userdata/#{game.name}/nethack4/dumplog/#{game.dumplog.tr("_",":")}"
        when "0.6.3"
            return "https://ascension.run/userdata/#{game.name}/sporkhack/dumplog/#{game.starttime}"
        when "NH-1.3d"
            return "https://ascension.run/userdata/#{game.name}/oldhack/dumplog/#{game.starttime}"
        when "slth"
            return "https://ascension.run/userdata/#{game.name}/slashthem/dumplog/#{game.starttime}"
        when "0.2.0"
            return "https://ascension.run/userdata/#{game.name}/grunthack/dumplog/#{game.starttime}"
        when "UNH"
            return "https://ascension.run/userdata/#{game.name}/unnethack/dumplog/#{game.starttime}.html"
        when "fiqhack"
            return "https://ascension.run/userdata/#{game.name}/fiqhack/dumplog/#{game.dumplog.tr("_",":")}"
        when "0.6.0"
            return "https://ascension.run/userdata/#{game.name}/dynahack/dumplog/#{game.dumplog}"
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
    Server.create name: 'esm_gho', variant: "GruntHack 0.2.1",
      url: 'https://em.slashem.me/', xlogurl: 'https://em.slashem.me/xlogfiles/grunthack', configfileurl: 'https://em.slashem.me/userdata/random_user/nethack/random_user.nh360rc'
    Server.create name: 'esm_shc', variant: "SporkHack 0.6.3",
      url: 'https://em.slashem.me/', xlogurl: 'https://em.slashem.me/xlogfiles/sporkhack', configfileurl: 'https://em.slashem.me/userdata/random_user/nethack/random_user.nh360rc'

    Server.create name: 'ndn_nao', variant: 'NetHack 3.4.3-NAO',
      url: 'https://ascension.run/', xlogurl: 'https://ascension.run/xlogfiles/nethack', configfileurl: 'https://ascension.run/userdata/random_user/nethack/nethackrc'
    Server.create name: 'ndn_unh', variant: 'UnNetHack 5.3.1',
      url: 'https://ascension.run/', xlogurl: 'https://ascension.run/xlogfiles/unnethack', configfileurl: 'https://ascension.run/userdata/random_user/nethack/nethackrc'
    Server.create name: 'ndn_dnh', variant: 'dNetHack 3.12.3',
      url: 'https://ascension.run/', xlogurl: 'https://ascension.run/xlogfiles/dnethack', configfileurl: 'https://ascension.run/userdata/random_user/nethack/nethackrc'
    Server.create name: 'ndn_dyn', variant: 'DynaHack 0.6.0',
      url: 'https://ascension.run/', xlogurl: 'https://ascension.run/xlogfiles/dynahack', configfileurl: 'https://ascension.run/userdata/random_user/nethack/nethackrc'
    #Server.create name: 'ndn_slth', variant: "SlashTHEM 0.8.0",
    #  url: 'https://ascension.run/', xlogurl: 'https://ascension.run/xlogfiles/slashthem', configfileurl: 'https://ascension.run/userdata/random_user/nethack/nethackrc'
    Server.create name: 'ndn_nh4k', variant: 'NetHack Fourk 4.3.0.3',
      url: 'https://ascension.run/', xlogurl: 'https://ascension.run/xlogfiles/nhfourk', configfileurl: 'https://ascension.run/userdata/random_user/nethack/nethackrc'
    Server.create name: 'ndn_fiq', variant: "FIQHack 4.3.0",
      url: 'https://ascension.run/', xlogurl: 'https://ascension.run/xlogfiles/fiqhack', configfileurl: 'https://ascension.run/userdata/random_user/nethack/nethackrc'
    Server.create name: 'nao_nh361', variant: 'NetHack 3.6.1-dev',
      url: 'https://nethack.alt.org/', xlogurl: 'https://alt.org/nethack/xlogfile.nh361dev', configfileurl: 'https://alt.org/nethack/userdata/random_user/random_user.nh360rc'
    Server.create name: 'ndn_nh4', variant: 'NetHack4 4.3.0',
      url: 'https://ascension.run/', xlogurl: 'https://ascension.run/xlogfiles/nethack4', configfileurl: 'https://ascension.run/userdata/random_user/nethack/nethackrc'


  end

  down do
    Server.destroy
  end
end
