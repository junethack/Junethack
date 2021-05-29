require 'rubygems'
require 'cgi'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/cache'
require 'database'
require 'haml'
require 'fetch_games'
require 'rufus/scheduler'
require 'trophy_calculations'
require 'helper'
require 'userscore'
require 'time'
require 'logger'
require 'sync'
require 'tournament_times'
require 'sanitize'

require 'graph'

require 'ext/numeric'

require 'rack/mobile-detect'
use Rack::MobileDetect

$db_access = Sync.new

## settings for sinatra-cache
# NB! you need to set the root of the app first
set :root, "#{Dir.pwd}"
set :cache_enabled, false  # complet
#set :cache_output_dir, "#{Dir.pwd}/cache"

# Listen to everything in development.
set :bind, "0.0.0.0"
set :port, ENV['JUNETHACK_PORT']||4567

#enable :sessions
use Rack::Session::Pool #fix 4kb session dropping
use Rack::Deflater
# Scheduler: fetch game data every 5 minutes
scheduler = Rufus::Scheduler.new
#scheduler.cron('*/5 * * * *', :blocking => true) { fetch_all }

$application_start = Time.new

# http://groups.google.com/group/rack-devel/browse_frm/thread/ffec93533180e98a
class WorkaroundLogger < Logger
  alias write <<
end
# log http requests
configure do
    Dir.mkdir('logs') unless File.exists?('logs')
    use Rack::CommonLogger, WorkaroundLogger.new('logs/access.log', 'daily')
end


before do
    @user = User.get(session['user_id'])
    @logged_in = @user.nil?
    @tournament_identifier = "junethack #{@user.login}" if @user
    @tournament_identifier_regexp = /junethack(2011)? #{Regexp.quote @user.login}/ if @user
    @messages = session["messages"] || []
    @errors = session["errors"] || []

    #puts "got #{@messages.length} messages"
    #puts "and #{@errors.length} errors"
    #puts "#{@errors.inspect}"
    session["messages"] = []
    session["errors"] = []

    # switch to a different layout for mobile devices
    @layout = env['X_MOBILE_DEVICE'] ? :layout_mobile : true
    # for debugging
    # @layout = :layout_mobile
    # puts env.sort.map{ |v| v.join(': ') }.join("\n") + "\n"

    $db_access.lock :SH
end

after do
    $db_access.unlock :SH
    #puts $db_access.inspect
end

def caching_check_last_played_game
end

def caching_check_last_played_game_by(user)
end

# TODO: replace this function with something more appropriate
def caching_check_application_start_time
    caching_check_last_played_game
end

get "/" do
    caching_check_application_start_time

    @show_banner = true
    haml :splash, :layout => @layout
end

get "/login" do
    caching_check_application_start_time

    @show_banner = true
    haml :login, :layout => @layout
end

get "/logout" do
    session['user_id'] = nil
    session['messages'] = ["Logged out"]

    redirect "/" and return
end

get "/trophies" do
    caching_check_application_start_time

    @show_banner = true
    haml :trophies, :layout => @layout
end

get "/trophies/:variant" do
    caching_check_application_start_time

    @variant = params[:variant]
    haml :variant_trophies, layout: @layout
end

get "/users" do
    caching_check_last_played_game

    @users = User.all
    haml :users, :layout => @layout
end

get "/about" do
    caching_check_application_start_time

    @show_banner = true
    haml :about, :layout => @layout
end

post "/login" do
    if user = User.authenticate(params["username"], params["password"])
        session['user_id'] = user.id
        #puts "Id is #{user.id}"
        session["messages"] 
        redirect "/home"
    else
        session["errors"] = ["Could not log in"]
        redirect "/login"
    end
end

get "/register" do
    caching_check_application_start_time

    @show_banner = true
    haml :register, :layout => @layout
end

get "/rules" do
    caching_check_application_start_time

    @show_banner = true
    haml :rules, :layout => @layout
end

get "/home" do
    redirect "/" and return unless session['user_id']

    @userscore = UserScore.new session['user_id']

    @user = User.get(session['user_id'])
    @user_id = @user.id

    @scoreentries = Scoreentry.all(:user_id => @user.id)

    @games_played = Game.all(:user_id => @user.id, :order => [ :endtime.desc ])
    @games_played_title = @user.display_game_statistics

    haml :home, :layout => @layout
end

post "/add_server_account" do
    redirect "/" and return unless session['user_id']

  $db_access.synchronize {
    server = Server.get(params[:server])

    session['errors'] << "Add account name!" and redirect "/home" and return if params[:user].strip.empty?

    # verify that this user wants to connect this account to this user
    begin
        if server.verify_user(params[:user], @tournament_identifier_regexp)
            session['messages'] << 'Account verified and added.'
        else
            session['errors'] << 'Could not find "# %s" in your config file on %s!' % [h(@tournament_identifier), h(server.display_name)]
            redirect "/home" and return
        end
    rescue Exception => e
        puts e
        session['errors'] << "Could not verify account!<br>" + (h e.message)
        redirect "/home" and return
    end
    if server.name.include?('hdf_')
      servers = Server.all.select {|s| s.name.include? 'hdf_' }
    else
      servers = Server.all(url: server.url)
    end
    servers.each {|server|
      begin
        account = Account.create(user: User.get(session['user_id']), server: server, name: params[:user], verified: true)
      rescue => e
        session['errors'].push(e.to_s)
      end
      # set user_id on all already played games
      Game.all(:name => params[:user], :server => server).update(:user_id => session['user_id']) if account
      repository.adapter.execute "UPDATE start_scummed_games SET user_id = ? WHERE name = ? AND server_id = ?", session['user_id'], params[:user], server.id
      repository.adapter.execute "UPDATE junk_games SET user_id = ? WHERE name = ? AND server_id = ?", session['user_id'], params[:user], server.id
    }
  }

    redirect "/home"
end

post "/create" do
  errors = []

  # don't allow registrations at wrong times
  now = Time.new.to_i
  if (now < $tournament_signupstarttime)
    errors.push("Tournament registration has not opened yet.")
  elsif (now >= $tournament_endtime)
    errors.push("Tournament has already ended.")
  end

  if (!errors.empty?)
    session['errors'] << errors
    redirect "/" and return
  end

  $db_access.synchronize {
    errors = []
    errors.push("Password and confirmation do not match.") if params["confirm"] != params["password"]
    errors.push("Username already exists.") if User.first(:login => params[:username])
    session['errors'] = errors
    puts "session errors are #{session['errors'].inspect}"
    redirect "/register" and return unless session['errors'].flatten.empty?
    user = User.new(:login => params["username"])
    user.password = params["password"]
    begin
        if user.save
            session['messages'] << "Registration successful. Please log in."
            Event.new(:text => "New user #{user.login} registered!", :url => "#{base_url}/user/#{user.login}").save
            redirect "/login" and return 
        else
            session['errors'] << "Could not register account"
            puts "could not register user #{params[:username]}"
            redirect "/register" and return
        end
    rescue
        session['errors'].push(*user.errors)
        puts "registering user threw an exception"
        puts "#{$!}"
        redirect "/register" and return
    end
  }
end

get "/user/:name" do
    caching_check_last_played_game_by(params[:name])

    @player = User.first(:login => params[:name])

    if @player
        @userscore = UserScore.new @player.id
        @scoreentries = Scoreentry.all(:user_id => @player.id)

        @games_played = Game.all(:user_id => @player.id, :order => [ :endtime.desc ])
        @games_played_title = @player.display_game_statistics

        @user_id = @player.id

        haml :user, :layout => @layout
    else
        session['errors'] << "Could not find user #{params[:name]}"
    end
end

get "/user_id/:id" do
    @player = User.first(:id => params[:id])
    if @player
        redirect "/user/"+CGI::escape(@player.login)
    else
        session['errors'] << "Could not find user_id #{params[:id]}"
    end
end

get "/clans" do
    caching_check_last_played_game

    @clans = Clan.all
    haml :clans, :layout => @layout
end

get "/clan/:name" do
    @clan = Clan.get(params[:name])
    if @clan
        puts "Invitations: #{@clan.invitations.inspect}"
        @admin = @clan.get_admin
        haml :clan, :layout => @layout
    else
        session['errors'] << "Could not find clan with id #{params[:name].inspect}"
        redirect "/clans"
    end
end

post '/clan_description/:name' do
  $db_access.synchronize {
    @clan = Clan.get(params[:name])
    redirect '/' if @clan.nil?
    redirect '/' if @user != @clan.get_admin

    if params[:description]
      @clan.description = params[:description]
      @clan.save!
    end
  }
  redirect "/clan/#{@clan.name}"
end

post '/clan_banner/:name' do
  $db_access.synchronize {
    @clan = Clan.get(params[:name])
    redirect '/' if @clan.nil?
    redirect '/' if @user != @clan.get_admin

    if params[:clear]
      @clan.gravatar = nil
    elsif params[:mail] && !params[:mail].empty?
      @clan.gravatar = Digest::MD5.hexdigest(params[:mail].downcase)
    end
    @clan.save!
  }
  redirect "/clan/#{@clan.name}"
end

post "/clan" do
  $db_access.synchronize {
    begin
      clan = Clan.create(:name => params[:clanname], :admin => [@user.id, 1])
    rescue
      session['errors'] << "There was an error creating the clan"
      redirect "/home" and return
    end
    if clan
      @user.clan = clan
      @user.save
      session['messages'] << "Successfully created clan #{params[:clanname]}"
      Event.new(:text => "New clan #{clan.name} created!", :url => "#{base_url}/clan/#{clan.name}").save
      redirect "/clan/" + CGI.escape(clan.name) and return
    else
      session['errors'] << "Could not create clan"
    end
  }
end
post "/clan/invite" do
  $db_access.synchronize {
    clan = Clan.get(params[:clan])

    # verify that clan admin is inviting other users
    if clan.admin[0] == @user.id
        invited_user = User.first(:login => params[:accountname])
        if not invited_user then
            session['errors'] << "Could not find Junethack username #{params[:accountname]}"
        else
            chars = ('a'..'z').to_a
            invitation = {'clan_id' => clan.name, 'status' => 'open', 'user' => @user.id, 'token' => (0..30).map{ chars[rand 26] }.join}
            clan.invitations.push(invitation)
            clan.save!
            invited_user.invitations.push(invitation)
            invited_user.save!
            session['messages'] << "Successfully invited #{invited_user.login} to #{clan.name}"
        end
    else
        sessions['errors'] << "You are not the clan admin"
    end
    redirect "/clan/#{CGI.escape(params[:clan])}"
  }
end
get "/respond/:token" do #respond to invitation
  $db_access.synchronize {
    puts "respond invite with params #{params.inspect}"
    invitation = @user.invitations.find{|inv| inv['token'] == params[:token]}
    if invitation
      accept = (params[:accept] == "true")
      if @user.respond_invite invitation, accept
        session['messages'] << "Successfully #{accept ? "accepted" : "declined"} invitation"
        @user.invitations.reject!{|inv| inv['token'] == params[:token]}
        if accept
          clan = Clan.first(:name => invitation['clan_id'])
          if clan
            @user.clan_name = clan.name
            @user.invitations = []
            @user.save
          end
        end
        @user.invitations = @user.invitations.to_json
        @user.save
      end
    else
      session['errors'] << "Could not find invitation"
    end
    redirect "/home"
  }
end
get "/clan/disband/:name" do
  $db_access.synchronize {
    clan = Clan.get(params[:name])
    if clan
        admin = clan.get_admin
        if clan.admin[0] == @user.id
            ClanScoreEntry.all(:clan_name => clan.name).destroy
            User.all(clan_name: clan.name).update(clan_name: nil)
            if clan.destroy
                session['messages'] << "Successfully disbanded #{params[:name]}"
            else
                session['errors'] << "Could not destroy clan"
            end
        else
            session['errors'] << "You are not the clan admin"
        end
    else
        session['errors'] << "Could not find clan #{params[:name]}"
    end
    redirect "/home"
  }
end

get "/leaveclan" do  #leave a clan
  $db_access.synchronize {
    redirect "/" and return unless @user
    if @user.clan
      if @user.clan.admin == [@user.id, 1]
        session['errors'] << "The clan admin can not leave the clan."
        redirect "/clan/#{CGI.escape(@user.clan.name)}" and return
      else
        clan_name = @user.clan.name
        @user.clan = nil
        @user.save
        session['messages'] << "Successfully left clan #{clan_name}"
      end
    else
      session['errors'] << "User has no clan"
    end
    redirect "/home"
  }
end

get "/scores/:name" do |name|
    # Is the user there? If not, just redirect to home
    @u = User.first(:login => name)
    if @u.nil? then
        session['errors'] << "No such user."
        redirect "/"
        return
    end
    @username = @u.login
    user_id = {:user_id => @u.id}
    @last_10_games = get_last_games(user_id)
    @most_ascended_users = most_ascensions_users(@u.id)
    haml :user_scores, :layout => @layout
end

get "/servers" do
    caching_check_application_start_time

    @servers = Server.all
    haml :servers, layout: @layout, locals: { verbose: false }
end

get "/servers/check" do
    @servers = Server.all
    haml :servers, layout: @layout, locals: { verbose: true }
end

get "/server/:name" do
    caching_check_last_played_game
    @server = Server.first(:name => params[:name])
    if @server
        @games = @server.games :conditions => [ 'user_id > 0' ], :order => [ :endtime.desc ], :limit => 100
        haml :server, :layout => @layout
    else
        session['errors'] << "Could not find server #{ params[:name] }"
        redirect "/"
    end
end

get "/server/:name/all" do
    caching_check_last_played_game
    @server = Server.first(:name => params[:name])
    if @server
        # limit by date for not permanently showing users that haven't
        # added themselves to Junethack
        @games = @server.games :conditions => [ "endtime > #{Time.new.to_i-7*60*60*24}" ], :order => [ :endtime.desc ], :limit => 100
        haml :server, :layout => @layout
    else
        session['errors'] << "Could not find server #{ params[:name] }"
        redirect "/"
    end
end

get %r{/games/?(\d{4}-\d{2}-\d{2})?/?([-0-9a-zNH.]+)?} do |date, variant|
    caching_check_last_played_game

    where = [ 'user_id is not null' ]
    @games_played_user_links = true
    title_variant = '';
    title_date = '';

    if variant
      title_variant = " for #{$variants_mapping[variant]}"
      where << "version = '#{variant}'"
    end

    if date
      title_date = " on #{date}"
      date = Time.parse("#{date} 00:00:00Z").to_i
      where << "endtime >= #{date} and endtime < #{date+86400}"
    end

    hash = { conditions: [where.join(' AND ')], order: [ :endtime.desc ] }
    hash[:limit] = 100 unless (date && variant)

    @games_played = Game.all(hash)
    @games_played_title = "Last #{@games_played.size} games played" + title_variant + title_date

    haml :last_games_played, :layout => @layout
end

get "/ascensions" do
    caching_check_last_played_game

    @games_played = Game.all(:conditions => [ "user_id is not null and ascended='t'" ], :order => [ :endtime.desc ])
    @games_played_user_links = true
    @games_played_title = "#{@games_played.size} ascended games"
    haml :last_games_played, :layout => @layout
end

get "/activity" do
    caching_check_last_played_game

    haml :activity, :layout => @layout
end

get "/deaths" do
    caching_check_last_played_game

    haml :deaths, :layout => @layout
end

get "/scoreboard" do
    caching_check_last_played_game

    haml :scoreboard, :layout => @layout
end

get "/trophy_scoreboard" do
    caching_check_last_played_game

    haml :trophy_scoreboard, :layout => @layout
end

get "/player_scoreboard" do
    caching_check_last_played_game

    haml :player_scoreboard, :layout => @layout
end

get "/post_tournament_statistics" do
    caching_check_last_played_game

    haml :post_tournament_statistics, :layout => @layout
end

get "/junethack.rss" do
  # determine date of last event or news
  last_event = Event.first order: [ :created_at.desc ], :created_at.lte => DateTime.now
  last_news  = News.first  order: [ :created_at.desc ], :created_at.lte => DateTime.now
  event = [last_event, last_news].compact.map(&:created_at).max

  etag "#{event}".hash if event
  last_modified event.httpdate if event

  content_type 'application/rss+xml'
  haml(:rss, :format => :xhtml, :escape_html => true, :layout => false)
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  # overwrite cache_fragment
  # it doesn't honor the setting of :environment
  if not production?
    def cache_fragment(fragment_name, shared = nil, &block)
      block.call
    end
  end

  # http://stackoverflow.com/questions/2950234/get-absolute-base-url-in-sinatra
  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end
end
