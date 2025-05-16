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
    ignored_game_modes = ['explore','multiplayer','debug','polyinit','setseed','abnormal',
                          'lostsoul','uberlostsoul','gmmode','supergmmode','wonderland']
    if File.exists? @stop_fetching_games then
      @fetch_logger.info "File #{@stop_fetching_games} exists, don't get new games."
      return
    end
    @fetch_logger.info "Looking for new games..."
    for server in Server.all
      begin
        count_games = 0
        count_scummed_games = 0
        count_junk_games = 0
        count_non_tournament_games = 0

        @fetch_logger.debug "server #{server.name} start!"
        @fetch_logger.debug "url #{server.xlogurl}"
        header = XLog.parse_header XLog.fetch_header(server.xlogurl)
        @fetch_logger.debug "fetched header #{header.inspect}"
        @fetch_logger.debug "current offset: #{server.xlogcurrentoffset}"
        if server.xlogcurrentoffset == nil
            server.xlogcurrentoffset = header['content-length'].to_i
            server.xloglastmodified = header['last-modified'] || 'Thu, 01 Jan 1970 00:00:00 GMT'
            $db_access.synchronize { server.save }
            next
        end

        # in case the web server doesn't send Last-Modified, use current time
        # because of byte-range fetching, not much overhead is generated
        last_modified = header['last-modified'] || Time.now.httpdate
        @fetch_logger.debug "last-modified #{last_modified}"
        if DateTime.parse(server.xloglastmodified) < DateTime.parse(last_modified)
            @fetch_logger.debug "fetching games ...."
            if gamesIO = XLog.fetch_from_xlog(server.xlogurl, server.xlogcurrentoffset, header['content-length'])
                games = gamesIO.readlines
                @fetch_logger.info "#{games.length} new game#{'s' if games.length != 1} on #{server.name}."
                i = 0
                    #repository.adapter.execute("BEGIN IMMEDIATE TRANSACTION");
                    games.each do |line|
                      begin
                        $db_access.lock :EX
                        #@fetch_logger.debug $db_access.inspect

                        i += 1
                        #@fetch_logger.debug "#{line.length} #{line}"
                        xlog_add_offset = line.length
                        hgame = XLog.parse_xlog line.force_encoding(Encoding::UTF_8).encode("utf-8", invalid: :replace)
                        if hgame['starttime'].to_i >= $tournament_starttime and
                            hgame['endtime'].to_i   <= $tournament_endtime
                            acc = Account.first(:name => hgame["name"], :server_id => server.id)
                            regular_game = false
                            hgame['modes'] ||= ""
                            hgame['gamemode'] ||= ""
                            modes = [hgame['mode']] + hgame['modes'].split(',') + hgame['gamemode'].split(',')

                            start_scummed = hgame['turns'].to_i <= 10 && ['escaped','quit'].include?(hgame['death'])
                            junk = (ignored_game_modes & modes).size > 0
                            junk ||= hgame['tournament'] == 'no' && server.name == 'acc_gnl' # Gnollhack tournament mode

                            if start_scummed then
                                game = StartScummedGame.create({server: server}.merge(hgame))
                                @fetch_logger.debug "start scummed game"
                                count_scummed_games += 1
                            elsif junk then
                                game = JunkGame.create({server: server}.merge(hgame))
                                @fetch_logger.debug "junk game"
                                count_junk_games += 1
                            elsif ([nil, 'hah', 'hoh', 'normal', 'solo', 'challenge'] & modes) != [] then
                              game = Game.create({server: server}.merge(hgame))
                                count_games += 1
                                regular_game = true
                            else
                              raise "Unknown 'mode' value: #{modes.inspect}"
                            end
                            if acc then
                              game.user_id = acc.user_id

                              if regular_game then
                                Event.new(:text => "#{game.user.login} ascended a game of #{$variants_mapping[game.version]} on #{game.server.hostname}!").save if game.ascended

                                # record some gaming milestones
                                games_count = (Game.count :conditions => [ 'user_id > 0' ])+1
                                if games_count == 100 or
                                   games_count == 500 or
                                   games_count % 1000 == 0 then
                                  Event.new(:text => "#{games_count} games have been played!").save
                                end

                              end
                            end

                            if game.save
                                @fetch_logger.debug "created #{i}"
                            else
                                raise "something went wrong, could not create games"
                            end

                        else
                            @fetch_logger.debug "not part of tournament #{i}"
                            count_non_tournament_games += 1
                        end
                        # this game is completely input into the db
                        # don't parse it again
                        server.xlogcurrentoffset += xlog_add_offset
                        server.save
                      ensure
                        $db_access.unlock :EX
                        #@fetch_logger.debug $db_access.inspect
                      end
                    end
                    #repository.adapter.execute("COMMIT");
                raise "xlogcurrentoffset mismatch: #{server.xlogcurrentoffset} != #{header['content-length'].to_i}" if server.xlogcurrentoffset != header['content-length'].to_i
                @fetch_logger.info "Inserted #{count_games} tournament, #{count_non_tournament_games} non tournament, #{count_scummed_games} start scummed, and #{count_junk_games} junk games on #{server.name}."
            else
                @fetch_logger.debug "No games at all on #{server.name}!"
            end
            server.xloglastmodified = last_modified
            $db_access.synchronize { server.save }
        else
            @fetch_logger.debug "No new games on #{server.name}."
        end
      rescue Exception => e
          @fetch_logger.error e.to_s
          @fetch_logger_error.error e
      end
    end
end
