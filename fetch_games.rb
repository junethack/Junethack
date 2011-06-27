require 'rubygems'
require 'date'
require 'database'
require 'parse'
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
                for hgame in games
                    #puts hgame.inspect
                    game = server.games.create!(hgame.merge({"server" => server}))
                    #puts "Created game #{game.inspect}"
                    if game.save
                        puts "created!"
                    else    
                        puts "something went wrong, could not create games"
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
