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
        open(configfileurl.gsub("random_user_initial", CGI::escape(user[0]))
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
            "https://#{prefix}.hardfought.org/userdata/#{player}/nethack/dumplog/#{game.starttime}.nh.html"
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
        [:nao_nh36, 'NetHack 3.6.6', 'https://alt.org/nethack/xlogfile.nh363+'],
      ].each {|server|
        url = 'https://nethack.alt.org/'
        configfileurl = 'https://alt.org/nethack/userdata/random_user/random_user.nh366rc'
        Server.create name: server[0], variant: server[1], url: url, xlogurl: server[2], configfileurl: configfileurl
      }

      [
        [:asc_nao,  'NetHack 3.4.3-nao',     'https://ascension.run/xlogfiles/nethack'],
        [:asc_unh,  'UnNetHack 5.3.2',       'https://ascension.run/xlogfiles/unnethack'],
        [:asc_dnh,  'dNetHack 3.18.0',       'https://ascension.run/xlogfiles/dnethack'],
        [:asc_dyn,  'DynaHack 0.6.0',        'https://ascension.run/xlogfiles/dynahack'],
        [:asc_nh4k, 'NetHack Fourk 4.3.0.4', 'https://ascension.run/xlogfiles/nhfourk'],
        [:asc_fiq,  'FIQHack 4.3.1',         'https://ascension.run/xlogfiles/fiqhack'],
        [:asc_nh4,  'NetHack4 4.3.0',        'https://ascension.run/xlogfiles/nethack4'],
      ].each {|server|
        url = 'https://ascension.run/'
        configfileurl = 'https://ascension.run/userdata/random_user/nethack/nethackrc'

        Server.create name: server[0], variant: server[1], url: url, xlogurl: server[2], configfileurl: configfileurl
      }

      Server.create name: 'nh4', variant: 'NetHack4 4.3.0',
        url: 'http://nethack4.org/', xlogurl: 'http://nethack4.org/xlogfile.txt', configfileurl: 'http://nethack4.org/junethack-rc/random_user.rc'

      [
        [:esm_nh36,  'NetHack 3.6.6',           'https://em.slashem.me/xlogfiles/nethack'],
        [:esm_slex,  "Slash'EM Extended 2.6.6", 'https://em.slashem.me/xlogfiles/slex'],
        [:esm_gho,   'GruntHack 0.2.4',         'https://em.slashem.me/xlogfiles/grunthack'],
        [:esm_shc,   'SporkHack 0.6.5',         'https://em.slashem.me/xlogfiles/sporkhack'],
        [:esm_dslex, 'DNetHack SLEX 3.16.0',    'https://em.slashem.me/xlogfiles/dnhslex'],
        [:esm_ndnh,  'notdNetHack 2020.04.16',  'https://em.slashem.me/xlogfiles/notdnh'],
        [:esm_slsh,  "Slash'EM 0.0.8E0F2",      'https://em.slashem.me/xlogfiles/slashem'],
      ].each {|server|
        url = 'https://em.slashem.me/'
        configfileurl = 'https://em.slashem.me/userdata/random_user/nethack/random_user.nh360rc'

        Server.create name: server[0], variant: server[1], url: url, xlogurl: server[2], configfileurl: configfileurl
      }

      prefixes = { us: :www, eu: :eu, au: :au }
      [:us, :eu, :au].each {|location|
        prefix = prefixes[location]
        [
          [:hdf_nao,  'NetHack 3.4.3-hdf',       "https://#{prefix}.hardfought.org/xlogfiles/nh343/xlogfile"],
          [:hdf_nh37, 'NetHack 3.7.0-hdf',       "https://#{prefix}.hardfought.org/xlogfiles/nethack/xlogfile-370-hdf"],
          [:hdf_shc,  'SporkHack 0.6.5',         "https://#{prefix}.hardfought.org/xlogfiles/sporkhack/xlogfile"],
          [:hdf_gho,  'GruntHack 0.2.4',         "https://#{prefix}.hardfought.org/xlogfiles/gh/xlogfile"],
          [:hdf_unh,  'UnNetHack 5.3.2',         "https://#{prefix}.hardfought.org/xlogfiles/unnethack/xlogfile"],
          [:hdf_dnh,  'dNetHack 3.19.1',         "https://#{prefix}.hardfought.org/xlogfiles/dnethack/xlogfile"],
          [:hdf_nh4,  'NetHack4 4.3.0',          "https://#{prefix}.hardfought.org/xlogfiles/nethack4/xlogfile"],
          [:hdf_nh4k, 'NetHack Fourk 4.3.0.4',   "https://#{prefix}.hardfought.org/xlogfiles/4k/xlogfile"],
          [:hdf_fiq,  'FIQHack 4.3.1',           "https://#{prefix}.hardfought.org/xlogfiles/fh/xlogfile"],
          [:hdf_dyn,  'DynaHack 0.6.0',          "https://#{prefix}.hardfought.org/xlogfiles/dynahack/xlogfile"],
          [:hdf_slex, "Slash'EM Extended 2.6.6", "https://#{prefix}.hardfought.org/xlogfiles/slex/xlogfile"],
          [:hdf_xnh,  'xNetHack 5.1',            "https://#{prefix}.hardfought.org/xlogfiles/xnethack/xlogfile"],
          [:hdf_spl,  'SpliceHack 0.7.1',        "https://#{prefix}.hardfought.org/xlogfiles/splicehack/xlogfile"],
          [:hdf_ndnh, 'notdNetHack 2020.04.16',  "https://#{prefix}.hardfought.org/xlogfiles/notdnethack/xlogfile"],
          [:hdf_evh,  'EvilHack 0.5.0',          "https://#{prefix}.hardfought.org/xlogfiles/evilhack/xlogfile"],
          [:hdf_slsh, "Slash'EM 0.0.8E0F2",      "https://#{prefix}.hardfought.org/xlogfiles/slashem/xlogfile"],
          [:hdf_13d,  'NetHack 1.3d',            "https://#{prefix}.hardfought.org/xlogfiles/nh13d/xlogfile"],

        ].each {|server|
          url = "https://#{prefix}.hardfought.org/nethack"

          server[0] = server[0].to_s.sub('h', 'euh').to_sym if location == :eu
          server[0] = server[0].to_s.sub('h', 'auh').to_sym if location == :au

          configfileurl = "https://#{prefix}.hardfought.org/userdata/random_user_initial/random_user/nh343/random_user.nh343rc"
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

DataMapper::MigrationRunner.migration( 9, :recreate_servers ) do
  up do
    Server.destroy!
    Server.create_servers
  end
end

DataMapper::MigrationRunner.migration(10, :hdf_fix ) do
  up do
    Server.all.select {|server| server.name =~ /hdf_nh36/ }.each {|server|
      server.accounts.destroy!
      server.destroy!
    }
  end
end

DataMapper::MigrationRunner.migration(11, :esm_slashem ) do
  up do
    [
      [:esm_slsh, "Slash'EM 0.0.8E0F2", 'https://em.slashem.me/xlogfiles/slashem'],
    ].each {|server|
      url = 'https://em.slashem.me/'
      configfileurl = 'https://em.slashem.me/userdata/random_user/nethack/random_user.nh360rc'

      Server.create name: server[0], variant: server[1], url: url, xlogurl: server[2], configfileurl: configfileurl
    }
  end
end

DataMapper::MigrationRunner.migration(12, :add_gnollhack_servers ) do
  up do
    prefixes = { us: :server, eu: 'eu-server', au: 'au-server' }
    [:us, :eu, :au].each {|location|
      prefix = prefixes[location]
      [
        [:gnl_hck, 'GnollHack', "http://#{prefix}.gnollhack.com/xlogfile"]
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

DataMapper::MigrationRunner.migration(13, :fix_hdf_accounts ) do
  up do
    hdf_13 = Server.first(name: 'hdf_13d')
    hdf_37 = Server.first(name: 'hdf_nh37')
    user_ids = Account.all(server: hdf_13).map(&:user_id) - Account.all(server: hdf_37).map(&:user_id)

    servers = [:hdf_nh37, :euhdf_nh37, :auhdf_nh37, :hdf_slsh, :euhdf_slsh, :auhdf_slsh].map {|name|
      Server.first(name: name)
    }

    user_ids.each {|user_id|
      user = User.first(id: user_id)

      servers.each {|server|
        account = Account.first(server: hdf_13, user_id: user_id)

        Account.create!(user: user, server: server, name: account.name, verified: true)

        Game.all(name: account.name, server: server).update(user_id: user_id)
        execute "UPDATE start_scummed_games SET user_id = ? WHERE name = ? AND server_id = ?", user_id, account.name, server.id
        execute "UPDATE junk_games SET user_id = ? WHERE name = ? AND server_id = ?", user_id, account.name, server.id
      }
    }
  end
end

DataMapper::MigrationRunner.migration(14, :fix_esm_accounts ) do
  up do
    esm_nh36 = Server.first(name: 'esm_nh36')
    esm_slsh = Server.first(name: 'esm_slsh')
    user_ids = Account.all(server: esm_nh36).map(&:user_id) - Account.all(server: esm_slsh).map(&:user_id)

    server = esm_slsh

    user_ids.each {|user_id|
      user = User.first(id: user_id)

      account = Account.first(server: esm_nh36, user_id: user_id)

      Account.create!(user: user, server: server, name: account.name, verified: true)

      Game.all(name: account.name, server: server).update(user_id: user_id)
      execute "UPDATE start_scummed_games SET user_id = ? WHERE name = ? AND server_id = ?", user_id, account.name, server.id
      execute "UPDATE junk_games SET user_id = ? WHERE name = ? AND server_id = ?", user_id, account.name, server.id
    }
  end
end
