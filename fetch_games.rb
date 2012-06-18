require 'rubygems'
require 'date'
require 'time'
require 'database'
require 'parse'
require 'logger'
require 'tournament_times'

Dir.mkdir('logs') unless File.exists?('logs')
@fetch_logger = Logger.new('logs/fetch_games.log', 'daily')
@fetch_logger_error = Logger.new('logs/fetch_games_errors.log', 'daily')

@stop_fetching_games = "stop_fetching_games"

def fetch_all
    if File.exists? @stop_fetching_games then
      @fetch_logger.info "File #{@stop_fetching_games} exists, don't get new games."
      return
    end
    for server in Server.all
      begin
        count_games = 0
        count_scummed_games = 0
        count_non_tournament_games = 0

        @fetch_logger.info "server #{server.name} start!"
        @fetch_logger.info "url #{server.xlogurl}"
        header = XLog.parse_header XLog.fetch_header(server.xlogurl)
        @fetch_logger.info "fetched header #{header.inspect}"
        @fetch_logger.info "current offset: #{server.xlogcurrentoffset}"
        if server.xlogcurrentoffset == nil
            server.xlogcurrentoffset = header['Content-Length'].to_i
            server.xloglastmodified = header['Last-Modified']
            $db_access.synchronize { server.save }
            next
        end

        # in case the web server doesn't send Last-Modified, use current time
        # because of byte-range fetching, not much overhead is generated
        last_modified = header['Last-Modified'] || Time.now.httpdate
        @fetch_logger.info "last-modified #{last_modified}"
        if DateTime.parse(server.xloglastmodified) < DateTime.parse(last_modified)
            @fetch_logger.info "fetching games ...."
            if gamesIO = XLog.fetch_from_xlog(server.xlogurl, server.xlogcurrentoffset, header['Content-Length'])
                games = gamesIO.readlines
                @fetch_logger.info "So many games ... #{games.length}"
                i = 0
                    games.each do |line|
                      begin
                        $db_access.lock :EX
                        @fetch_logger.debug $db_access.inspect

                        i += 1
                        #@fetch_logger.debug "#{line.length} #{line}"
                        xlog_add_offset = line.length
                        hgame = XLog.parse_xlog line
                        strange_acehack_mode = hgame['mode'] == 'explore' or hgame['mode'] == 'multiplayer'
                        if hgame['starttime'].to_i >= $tournament_starttime and
                            hgame['endtime'].to_i   <= $tournament_endtime and not strange_acehack_mode
                            acc = Account.first(:name => hgame["name"], :server_id => server.id)
                            if hgame['turns'].to_i <= 10 and ['escaped','quit'].include? hgame['death'] then
                                game = StartScummedGame.create(hgame.merge({"server" => server}))
                                @fetch_logger.info "start scummed game"
                                count_scummed_games += 1
                            else
                                game = Game.create(hgame.merge({"server" => server}))
                                count_games += 1
                            end
                            game.user_id = acc.user_id if acc
                            if game.save
                                @fetch_logger.info "created #{i}"
                            else
                                raise "something went wrong, could not create games"
                            end
                        else
                            @fetch_logger.info "not part of tournament #{i}"
                            count_non_tournament_games += 1
                        end
                        # this game is completely input into the db
                        # don't parse it again
                        server.xlogcurrentoffset += xlog_add_offset
                        server.save
                      ensure
                        $db_access.unlock :EX
                        @fetch_logger.debug $db_access.inspect
                      end
                    end
                raise "xlogcurrentoffset mismatch: #{server.xlogcurrentoffset} != #{header['Content-Length'].to_i}" if server.xlogcurrentoffset != header['Content-Length'].to_i
                @fetch_logger.info "Inserted #{count_games} tournament, #{count_non_tournament_games} non tournament. and #{count_scummed_games} start scummed games."
            else
                @fetch_logger.info "No games at all!"
            end
            server.xloglastmodified = last_modified
            $db_access.synchronize { server.save }
        else
            @fetch_logger.info "no new games, try again later"
        end
      rescue Exception => e
          @fetch_logger.error e.to_s
          @fetch_logger_error.error e
      end
    end
end
