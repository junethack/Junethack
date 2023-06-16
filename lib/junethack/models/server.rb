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
        URI::open(configfileurl.gsub("random_user_initial", CGI::escape(user[0]))
                               .gsub("random_user", CGI::escape(user))) do |f|
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
      when "nethack.alt.org"
        case game.version
        when "3.6"
          return "https://altorg.s3.amazonaws.com/dumplog/#{game.name}/#{game.starttime}.nh#{game.old_version.gsub('.','')}.txt"
        end
      when "grunthack.org"
        return "http://grunthack.org/userdata/#{game.name[0..0]}/#{game.name}/dumplog/#{game.starttime}.gh020.txt"
      when "nethack.dank.ninja", "ascension.run"
        case game.version
        when "3.4.3"
            return "https://ascension.run/userdata/#{game.name}/nethack/dumplog/#{game.starttime}"
        when "dnh"
            return "https://ascension.run/userdata/#{game.name}/dnethack/dumplog/#{game.starttime}"
        when "nh4k"
            return "https://ascension.run/userdata/#{game.name}/nhfourk/dumplog/#{game.dumplog.tr("_",":")}"
        when "nh4"
            return "https://ascension.run/userdata/#{game.name}/nethack4/dumplog/#{game.dumplog.tr("_",":")}"
        when "shc"
            return "https://ascension.run/userdata/#{game.name}/sporkhack/dumplog/#{game.starttime}"
        when "NH-1.3d"
            return "https://ascension.run/userdata/#{game.name}/oldhack/dumplog/#{game.starttime}"
        when "slth"
            return "https://ascension.run/userdata/#{game.name}/slashthem/dumplog/#{game.starttime}"
        when "gho"
            return "https://ascension.run/userdata/#{game.name}/grunthack/dumplog/#{game.starttime}"
        when "unh"
          return "https://ascension.run/userdata/#{game.name}/unnethack/dumplog/#{game.starttime}.html"
        when "fiq"
            return "https://ascension.run/userdata/#{game.name}/fiqhack/dumplog/#{game.dumplog.tr("_",":")}"
        when "dyn"
            return "https://ascension.run/userdata/#{game.name}/dynahack/dumplog/#{game.dumplog}"
        end
      when "nethack4.org"
        return nil if game.dumplog.nil?
        "http://nethack4.org/dumps/#{game.dumplog.tr("_",":")}"
      when /hardfought.org/
        player = "#{game.name[0..0]}/#{game.name}"
        prefix = 'eu' if hostname.start_with?('eu.')
        prefix = 'au' if hostname.start_with?('au.')
        prefix ||= 'www'
        case game.version
        when "dyn"
            "https://#{prefix}.hardfought.org/userdata/#{player}/dynahack/dumplog/#{game.dumplog}"
        when "gho"
            "https://#{prefix}.hardfought.org/userdata/#{player}/gh/dumplog/#{game.starttime}.gh.txt"
        when "3.6", "3.7"
          if game.server.name.end_with?("nh37s")
            "https://#{prefix}.hardfought.org/userdata/#{player}/setseed/dumplog/#{game.starttime}.seed.html"
          else
            "https://#{prefix}.hardfought.org/userdata/#{player}/nethack/dumplog/#{game.starttime}.nh.html"
          end
        when "unh"
            "https://#{prefix}.hardfought.org/userdata/#{player}/unnethack/dumplog/#{game.starttime}.un.txt.html"
        when "fiq"
            "https://#{prefix}.hardfought.org/userdata/#{player}/fiqhack/dumplog/#{game.dumplog.tr("_",":")}"
        when "nh4k"
            "https://#{prefix}.hardfought.org/userdata/#{player}/nhfourk/dumps/#{game.dumplog.tr("_",":")}"
        when "nh4"
            "https://#{prefix}.hardfought.org/userdata/#{player}/nethack4/dumplog/#{game.dumplog.tr("_",":")}"
        when "dnh"
            "https://#{prefix}.hardfought.org/userdata/#{player}/dnethack/dumplog/#{game.starttime}.dnh.txt"
        when "3.4.3"
            "https://#{prefix}.hardfought.org/userdata/#{player}/nh343/dumplog/#{game.starttime}.nh343.txt"
        when "shc"
            "https://#{prefix}.hardfought.org/userdata/#{player}/sporkhack/dumplog/#{game.starttime}.sp.txt"
        when "slex"
            "https://#{prefix}.hardfought.org/userdata/#{player}/slex/dumplog/#{game.starttime}.slex.txt"
        when "spl"
            "https://#{prefix}.hardfought.org/userdata/#{player}/splicehack/dumplog/#{game.starttime}.splice.html"
        when "xnh"
            "https://#{prefix}.hardfought.org/userdata/#{player}/xnethack/dumplog/#{game.starttime}.xnh.html"
        when "evh"
            "https://#{prefix}.hardfought.org/userdata/#{player}/evilhack/dumplog/#{game.starttime}.evil.html"
        when "ndnh"
            "https://#{prefix}.hardfought.org/userdata/#{player}/notdnethack/dumplog/#{game.starttime}.ndnh.txt"
        when "slashem"
            "https://#{prefix}.hardfought.org/userdata/#{player}/slashem/dumplog/#{game.starttime}.slashem.txt"
        when "NH-1.3d"
            "https://#{prefix}.hardfought.org/userdata/#{player}/nh13d/dumplog/#{game.starttime}.nh13d.txt"
        when "slth"
            "https://#{prefix}.hardfought.org/userdata/#{player}/slashthem/dumplog/#{game.starttime}.slth.txt"
        when "gnl"
            "https://#{prefix}.hardfought.org/userdata/#{player}/gnollhack/dumplog/#{game.starttime}.gnoll.txt"
        when "hck"
            "https://#{prefix}.hardfought.org/userdata/#{player}/hackem/dumplog/#{game.starttime}.hackem.html"
        end
      when "em.slashem.me"
        case game.version
        when "3.6"
          endtime = DateTime.strptime(game.endtime.to_s,"%s").strftime("%Y%m%d%H%M%S")
          "https://em.slashem.me/userdata/#{game.name}/nethack/dumplog/#{endtime}.txt"
        #when "slex"
        #  "https://em.slashem.me/userdata/#{game.name}/slex/dumplog/#{endtime}.txt"
        when "gho"
          "https://em.slashem.me/userdata/#{game.name}/grunthack/dumplog/#{game.starttime}.txt"
        when "shc"
          "https://em.slashem.me/userdata/#{game.name}/sporkhack/dumplog/#{game.starttime}.txt"
        when "slashem"
          starttime = DateTime.strptime(game.starttime.to_s,"%s").strftime("%Y%m%d%H%M%S")
          "https://em.slashem.me/userdata/#{game.name}/slashem-008/dumplog/#{starttime}.txt"
        end
      when "server.gnollhack.com"
        "http://server.gnollhack.com/userdata/#{game.name}/dumplog/gnollhack.#{game.name}.#{game.starttime}.log"
      when "eu-server.gnollhack.com"
        "http://eu-server.gnollhack.com/userdata/#{game.name}/dumplog/gnollhack.#{game.name}.#{game.starttime}.log"
      when "au-server.gnollhack.com"
        "http://au-server.gnollhack.com/userdata/#{game.name}/dumplog/gnollhack.#{game.name}.#{game.starttime}.log"
      else
        return nil
      end
    end

    def self.create_servers
      [
        [:nao_nh36, 'NetHack 3.6.7', 'https://alt.org/nethack/xlogfile.nh363+'],
      ].each {|server|
        url = 'https://nethack.alt.org/'
        configfileurl = 'https://alt.org/nethack/userdata/random_user/random_user.nh366rc'
        Server.create name: server[0], variant: server[1], url: url, xlogurl: server[2], configfileurl: configfileurl
      }

      Server.create name: 'nh4', variant: 'NetHack4 4.3.0',
        url: 'http://nethack4.org/', xlogurl: 'http://nethack4.org/xlogfile.txt', configfileurl: 'http://nethack4.org/junethack-rc/random_user.rc'

      prefixes = { us: :www, eu: :eu, au: :au }
      [:us, :eu, :au].each {|location|
        prefix = prefixes[location]
        [
          [:hdf_nao,  'NetHack 3.4.3-hdf',       "https://#{prefix}.hardfought.org/xlogfiles/nh343/xlogfile"],
          [:hdf_nh37, 'NetHack 3.7.0-hdf',       "https://#{prefix}.hardfought.org/xlogfiles/nethack/xlogfile-370-hdf"],
          #[:hdf_nh37s, 'NetHack 3.7.0-hdf (seed)', "https://#{prefix}.hardfought.org/xlogfiles/setseed/xlogfile"],
          [:hdf_shc,  'SporkHack 0.7.0',         "https://#{prefix}.hardfought.org/xlogfiles/sporkhack/xlogfile"],
          [:hdf_gho,  'GruntHack 0.3.0',         "https://#{prefix}.hardfought.org/xlogfiles/gh/xlogfile"],
          [:hdf_unh,  'UnNetHack 6.0.8',         "https://#{prefix}.hardfought.org/xlogfiles/unnethack/xlogfile"],
          [:hdf_dnh,  'dNetHack 3.22.0',         "https://#{prefix}.hardfought.org/xlogfiles/dnethack/xlogfile"],
          [:hdf_nh4,  'NetHack4 4.3.0',          "https://#{prefix}.hardfought.org/xlogfiles/nethack4/xlogfile"],
          [:hdf_nh4k, 'NetHack Fourk 4.3.0.5',   "https://#{prefix}.hardfought.org/xlogfiles/4k/xlogfile"],
          [:hdf_fiq,  'FIQHack 4.3.1',           "https://#{prefix}.hardfought.org/xlogfiles/fh/xlogfile"],
          [:hdf_dyn,  'DynaHack 0.6.0',          "https://#{prefix}.hardfought.org/xlogfiles/dynahack/xlogfile"],
          [:hdf_xnh,  'xNetHack 8.0.0',          "https://#{prefix}.hardfought.org/xlogfiles/xnethack/xlogfile"],
          [:hdf_spl,  'SpliceHack 1.2.0',        "https://#{prefix}.hardfought.org/xlogfiles/splicehack/xlogfile"],
          [:hdf_ndnh, 'notdNetHack 2023.05.15',  "https://#{prefix}.hardfought.org/xlogfiles/notdnethack/xlogfile"],
          [:hdf_evh,  'EvilHack 0.8.2',          "https://#{prefix}.hardfought.org/xlogfiles/evilhack/xlogfile"],
          [:hdf_slsh, "Slash'EM 0.0.8E0F2",      "https://#{prefix}.hardfought.org/xlogfiles/slashem/xlogfile"],
          [:hdf_slth, "SlashTHEM 0.9.7",         "https://#{prefix}.hardfought.org/xlogfiles/slashthem/xlogfile"],
          [:hdf_gnl,  "GnollHack 4.1.1",         "https://#{prefix}.hardfought.org/xlogfiles/gnollhack/xlogfile"],
          [:hdf_hck,  'HackEM 1.1.4',            "https://#{prefix}.hardfought.org/xlogfiles/hackem/xlogfile"],
          [:hdf_ace,  'AceHack 3.6.0',           "https://#{prefix}.hardfought.org/xlogfiles/acehack/xlogfile"],
          [:hdf_13d,  'NetHack 1.3d',            "https://#{prefix}.hardfought.org/xlogfiles/nh13d/xlogfile"],

        ].each {|server|
          url = "https://#{prefix}.hardfought.org/nethack"

          server[0] = server[0].to_s.sub('h', 'euh').to_sym if location == :eu
          server[0] = server[0].to_s.sub('h', 'auh').to_sym if location == :au

          configfileurl = "https://#{prefix}.hardfought.org/userdata/random_user_initial/random_user/nh343/random_user.nh343rc"
          Server.create name: server[0], variant: server[1], url: url, xlogurl: server[2], configfileurl: configfileurl
        }
      }

      prefixes = { us: :server, eu: 'eu-server', au: 'au-server' }
      [:us, :eu, :au].each {|location|
        prefix = prefixes[location]
        [
          [:gnl_hck, 'GnollHack 4.1.1', "http://#{prefix}.gnollhack.com/xlogfile"]
        ].each {|server|
          url = "http://#{prefix}.gnollhack.com/"

          server[0] = :us_gnl if location == :us
          server[0] = :eu_gnl if location == :eu
          server[0] = :au_gnl if location == :au

          configfileurl = "http://#{prefix}.gnollhack.com/userdata/random_user/random_user_gnollhack.gnhrc"
          Server.create name: server[0], variant: server[1], url: url, xlogurl: server[2], configfileurl: configfileurl
        }
      }
    end
end

DataMapper::MigrationRunner.migration( 1, :create_servers ) do
  up do
    Server.create_servers
  end

  down do
    Server.destroy
  end
end

DataMapper::MigrationRunner.migration( 2, :fix_nao_2023 ) do
  up do
    server = Server.first(name: 'nao_nh36')
    server.update(configfileurl: "https://alt.org/nethack/userdata/random_user_initial/random_user/random_user.nh367rc")
  end
end
