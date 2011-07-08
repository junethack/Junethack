require 'rubygems'
require 'date'
require 'time'
require 'database'
require 'parse'

$tournament_starttime = Time.parse("2011-07-01 00:00:00Z").to_i
$tournament_endtime   = Time.parse("2011-08-01 00:00:00Z").to_i

def fetch_all
    for server in Server.all
        puts "server #{server.name} start!"
        puts "url #{server.xlogurl}"
        header = XLog.parse_header XLog.fetch_header(server.xlogurl)
        puts "fetched header #{header.inspect}"
        puts "current offset: #{server.xlogcurrentoffset}"
        if server.xlogcurrentoffset == nil
            server.xlogcurrentoffset = header['Content-Length'].to_i
            server.xloglastmodified = header['Last-Modified']
            server.save
            return
        end
        if DateTime.parse(server.xloglastmodified) < DateTime.parse(header['Last-Modified'])
            puts "fetching games ...."
            if games = XLog.fetch_from_xlog(server.xlogurl, server.xlogcurrentoffset, header['Content-Length'])
                server.xlogcurrentoffset = header['Content-Length'].to_i
                puts "So many games ... #{games.length}"
                i = 0
               Game.transaction do
                for hgame in games
                    i += 1
                    #puts hgame.inspect
                    if hgame['starttime'].to_i >= $tournament_starttime and
                       hgame['endtime'].to_i   <= $tournament_endtime
                        acc = Account.first(:name => hgame["name"], :server_id => server.id)
                        game = Game.create!(hgame.merge({"server" => server}))
                        game.user_id = acc.user_id if acc
                        #puts "Created game #{game.inspect}"
                        if game.save
                            puts "created #{i}"
                        else
                            puts "something went wrong, could not create games"
                        end
                    else
                        puts "not part of tournament #{i}"
                    end
                end
               end
            else
                puts "No games at all!"
            end
            server.xloglastmodified = header['Last-Modified']
            server.save
        else    
            puts "no new games, try again later"
        end
    end    
end
