require 'rubygems'
require 'date'
require 'database'
require 'parse'
def fetch_all
	for server in Server.all
		puts "server #{server.name} start!"
		header = XLog.parse_header XLog.fetch_header(server.xlogurl)
		if DateTime.parse(server.xloglastmodified) < DateTime.parse(header['Last-Modified'])
			puts "fetching games ...."
			if games = XLog.fetch_from_xlog(server.xlogurl, server.xlogcurrentoffset, header['Content-Length'])
				server.xlogcurrentoffset = header['Content-Length'].to_i
				puts "So many games ... #{games.length}"
				for hgame in games
					puts hgame.inspect
					game = server.games.create(hgame.merge({"server" => server}))
					puts "created!"
	
				end
			else
				puts "No games at all!"
			end
			server.xloglastmodified = header['Last-Modified']
			server.save
		end
	end	
end
