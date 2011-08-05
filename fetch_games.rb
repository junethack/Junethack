require 'rubygems'
require 'date'
require 'time'
require 'database'
require 'parse'
require 'logger'

$tournament_starttime = Time.parse("2011-07-17 00:00:00Z").to_i
$tournament_endtime   = Time.parse("2011-08-15 00:00:00Z").to_i

Dir.mkdir('logs') unless File.exists?('logs')
@fetch_logger = Logger.new('logs/fetch_games.log', 'daily')
@fetch_logger_error = Logger.new('logs/fetch_games_errors.log', 'daily')

def fetch_all
    for server in Server.all
      begin
        @fetch_logger.info "server #{server.name} start!"
        @fetch_logger.info "url #{server.xlogurl}"
        header = XLog.parse_header XLog.fetch_header(server.xlogurl)
        @fetch_logger.info "fetched header #{header.inspect}"
        @fetch_logger.info "current offset: #{server.xlogcurrentoffset}"
        if server.xlogcurrentoffset == nil
            server.xlogcurrentoffset = header['Content-Length'].to_i
            server.xloglastmodified = header['Last-Modified']
            server.save
            next
        end
        if DateTime.parse(server.xloglastmodified) < DateTime.parse(header['Last-Modified'])
            @fetch_logger.info "fetching games ...."
            if gamesIO = XLog.fetch_from_xlog(server.xlogurl, server.xlogcurrentoffset, header['Content-Length'])
                games = gamesIO.readlines
                @fetch_logger.info "So many games ... #{games.length}"
                i = 0
                    games.each do |line|
                        i += 1
                        #@fetch_logger.debug "#{line.length} #{line}"
                        xlog_add_offset = line.length
                        hgame = XLog.parse_xlog line
                        if hgame['starttime'].to_i >= $tournament_starttime and
                            hgame['endtime'].to_i   <= $tournament_endtime
                            acc = Account.first(:name => hgame["name"], :server_id => server.id)
                            if hgame['turns'].to_i <= 10 and ['death','quit'].include? hgame['death'] then
                                game = StartScummedGame.create(hgame.merge({"server" => server}))
                                @fetch_logger.info "start scummed game"
                            else
                                game = Game.create(hgame.merge({"server" => server}))
                            end
                            game.user_id = acc.user_id if acc
                            if game.save
                                @fetch_logger.info "created #{i}"
                            else
                                raise "something went wrong, could not create games"
                            end
                        else
                            @fetch_logger.info "not part of tournament #{i}"
                        end
                        # this game is completely input into the db
                        # don't parse it again
                        server.xlogcurrentoffset += xlog_add_offset
                        server.save
                    end
                raise "xlogcurrentoffset mismatch: #{server.xlogcurrentoffset} != #{header['Content-Length'].to_i}" if server.xlogcurrentoffset != header['Content-Length'].to_i
            else
                @fetch_logger.info "No games at all!"
            end
            server.xloglastmodified = header['Last-Modified']
            server.save
        else
            @fetch_logger.info "no new games, try again later"
        end
      rescue Exception => e
          @fetch_logger.error e.to_s
          @fetch_logger_error.error e
      end
    end
end
