require 'rubygems'
require 'cgi'
require 'bundler/setup'
require 'sinatra'
require 'database'
require 'haml'
require 'fetch_games'
require 'rufus/scheduler'
require 'trophy_calculations'
require 'helper'
require 'userscore'
require 'time'
require 'logger'

#enable :sessions
use Rack::Session::Pool #fix 4kb session dropping
# Scheduler: fetch game data every 15 minutes
scheduler = Rufus::Scheduler.start_new
scheduler.cron('*/15 * * * *') { fetch_all }

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
    @tournament_identifier = "junethack2011 #{@user.login}" if @user
    @messages = session["messages"] || []
    @errors = session["errors"] || []

    puts "got #{@messages.length} messages"
    puts "and #{@errors.length} errors"
    puts "#{@errors.inspect}"
    session["messages"] = []
    session["errors"] = []
end

def caching_check_last_played_game
    last_played_game_time = repository.adapter.select("select max(endtime) from games where user_id is not null;")[0]

    etag last_played_game_time if last_played_game_time
    last_modified Time.at(last_played_game_time.to_i).httpdate if last_played_game_time
end

def caching_check_application_start_time
    etag $application_start if $application_start
    last_modified Time.at($application_start.to_i).httpdate if $application_start
end

get "/" do
    caching_check_application_start_time if not @user

    @show_banner = true
    haml :splash
end

get "/login" do
    caching_check_application_start_time

    @show_banner = true
    haml :login
end

get "/logout" do
    session['user_id'] = nil
    session['messages'] = ["Logged out"]

    redirect "/" and return
end

get "/trophies" do
    caching_check_application_start_time

    @show_banner = true
    haml :trophies
end

get "/users" do 
    caching_check_last_played_game

    @users = User.all :order => [ :login.asc ]
    haml :users
end

get "/about" do
    caching_check_application_start_time

    @show_banner = true
    haml :about
end

post "/login" do
    if user = User.authenticate(params["username"], params["password"])
        session['user_id'] = user.id
        puts "Id is #{user.id}"
        session["messages"] 
        redirect "/home"
    else
        session["errors"] = ["Could not log in"]
        redirect "/login"
    end
end
    
get "/register" do
    @show_banner = true
    haml :register
end

get "/rules" do
    caching_check_application_start_time

    @show_banner = true
    haml :rules
end

get "/home" do
    redirect "/" and return unless session['user_id']

    @userscore = UserScore.new session['user_id']

    @user = User.get(session['user_id'])
    @scoreentries = Scoreentry.all(:user_id => @user.id)

    @games_played = Game.all(:user_id => @user.id, :order => [ :endtime.desc ])
    @games_played_title = "Games played"

    haml :home
end

post "/add_server_account" do
    redirect "/" and return unless session['user_id']

    server = Server.get(params[:server])

    session['errors'] = "Add account name!" and redirect "/home" and return if params[:user].strip.empty?

    # verify that this user wants to connect this account to this user
    begin
        if server.verify_user(params[:user], Regexp.new(Regexp.quote(@tournament_identifier)))
            session['messages'] = 'Account verified and added.'
        else
            session['errors'] = 'Could not find "# %s" in your config file on %s!' % [h(@tournament_identifier), h(server.display_name)]
            redirect "/home" and return
        end
    rescue Exception => e
        puts e
        session['errors'] = "Could not verify account!<br>" + (h e.message)
        redirect "/home" and return
    end
    begin
        account = Account.create(:user => User.get(session['user_id']), :server => server, :name => params[:user], :verified => true)
    rescue
        session['errors'].push(*account.errors)
    end
    # set user_id on all already played games
    Game.all(:name => params[:user], :server => server).update(:user_id => session['user_id']) if account

    redirect "/home"
end

post "/create" do
    errors = []
    errors.push("Password and confirmation do not match.") if params["confirm"] != params["password"]
    errors.push("Username already exists.") if User.first(:login => params[:username])
    session['errors'] = errors
    puts "session errors are #{session['errors'].inspect}"
    redirect "/register" and return unless session['errors'].empty?
    user = User.new(:login => params["username"])
    user.password = params["password"]
    begin
        if user.save
            session['messages'] = "Registration successful. Please log in."
            redirect "/"
        else
            session['errors'] = "Could not register account"
            redirect "/register"
        end
    rescue
        session['errors'].push(*user.errors)
        redirect "/register"
    end
end

get "/user/:name" do
    caching_check_last_played_game

    @player = User.first(:login => params[:name])

    if @player
        @userscore = UserScore.new @player.id
        @scoreentries = Scoreentry.all(:user_id => @player.id)

        @games_played = Game.all(:user_id => @player.id, :order => [ :endtime.desc ])
        @games_played_title = "Games played"

        haml :user
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
    haml :clans
end
get "/clan/:name" do
    @clan = Clan.get(params[:name])   
    if @clan
        puts "Invitations: #{@clan.invitations.inspect}"
        @admin = @clan.get_admin
        haml :clan
    else
        session['errors'] << "Could not find clan with id #{params[:name].inspect}"
        redirect "/clans"
    end
end

post "/clan" do
    acc = Account.first(:user_id => @user.id, :server_id => params[:server].to_i)
    if acc
        begin
            clan = Clan.create(:name => params[:clanname], :admin => [acc.user.id, acc.server.id])
        rescue
            session['errors'].push(*clan.errors)
            redirect "/home" and return
        end
        acc.clan = clan
        acc.save
        @user.clan = clan.name
        @user.save
        session['messages'] << "Successfully created clan #{params[:clanname]}"
        puts CGI.escape(acc.clan.name)
        redirect "/clan/" + CGI.escape(acc.clan.name)
    else 
        session['errors'] << "Could not find your account on this server"
        redirect "/home"
    end
end
post "/clan/invite" do
    clan = Clan.get(params[:clan])
    
    if clan.admin[0] == @user.id
        acc = Account.first(:name => params[:accountname], :server_id => params[:server])
        if acc
            chars = ('a'..'z').to_a
            invitation = {'clan_id' => clan.name, 'status' => 'open', 'user' => acc.user.id, 'server' => params[:server], 'token' => (0..30).map{ chars[rand 26] }.join}
            clan.update(:invitations => (clan.invitations.push(invitation)).to_json)
            acc.update(:invitations => (acc.invitations.push(invitation)).to_json)
            session['messages'] << "Successfully invited #{acc.name} to #{clan.name}"
        else
            session['errors'] << "Could not find #{params[:accountname]} on #{params[:server]}"
        end
    else
        sessions['errors'] << "You are not the clan admin"
    end
    redirect "/clan/#{CGI.escape(params[:clan])}"
end
get "/respond/:server_id/:token" do #respond to invitation
    puts "respond invite with params #{params.inspect}"
    acc = @user.accounts.get(@user.id, params[:server_id].to_i)
    if acc
        invitation = acc.invitations.find{|inv| inv['token'] == params[:token]}
        if invitation
            accept = (params[:accept] == "true")
            if acc.respond_invite invitation, accept
                session['messages'] << "Successfully #{accept ? "accepted" : "declined"} invitation"
                acc.invitations.reject!{|inv| inv['token'] == params[:token]}
                if accept
                    acc.clan = Clan.first(:name => invitation['clan_id'])
                    @user.clan = acc.clan.name
                    @user.save
                end
                acc.invitations = acc.invitations.to_json
                acc.save
            end
        else
            session['errors'] << "Could not find invitation"
        end
    else
        session['errors'] << "Could not find account"
    end
    redirect "/home"
end
get "/clan/disband/:name" do
    clan = Clan.get(params[:name])
    if clan
        admin = clan.get_admin
        if @user.accounts.include? admin
            ClanScoreEntry.all(:clan_name => clan.name).destroy
            if clan.destroy
                session['messages'] << "Successfully disbanded #{params[:name]}"
                @user.clan = nil
                @user.save
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
end
            
get "/leaveclan/:server" do  #leave a clan
    redirect "/" and return unless @user
    if account = Account.get(@user.id, params[:server])
        
        puts "found account #{account.name}"
        if account.clan.admin == [account.user.id, account.server.id]
            session['errors'] << "The clan admin can not leave the clan."
            redirect "/clan/#{CGI.escape(account.clan.name)}" and return
        else

            clanname = account.clan.name
            account.clan = nil
            account.save
            @user.clan = nil
            @user.save
            session['messages'] << "Successfully left clan #{clanname}"
        end
    else
        session['errors'] << "No account on this server"
    end
    redirect "/home"
end        

get "/scores/:name" do |name|
    # Is the user there? If not, just redirect to home
    @u = User.first(:login => name)
    if @u.nil? then
        session['errors'] = "No such user."
        redirect "/"
        return
    end
    @username = @u.login
    user_id = {:user_id => @u.id}
    @last_10_games = get_last_games(user_id)
    @most_ascended_users = most_ascensions_users(@u.id)
    haml :user_scores
end

get "/scoreboard" do
    @most_ascended_users = most_ascensions_users

    @games_played = Game.all(:conditions => [ 'user_id is not null' ], :order => [ :endtime.desc ], :limit => 50)
    @games_played_user_links = true
    @games_played_title = "Last #{@games_played.size} games played"

    haml :scoreboard
end

get "/servers" do
    @servers = Server.all
    haml :servers
end

get "/server/:name" do
    @server = Server.first(:name => params[:name])
    if @server
        @games = @server.games :conditions => [ 'user_id is not null' ], :order => [ :endtime.desc ], :limit => 50
        haml :server
    else
        session['errors'] << "Could not find server #{ params[:name] }"
        redirect "/"
    end
end

get "/last_games_played" do
    caching_check_last_played_game

    @games_played = Game.all(:conditions => [ 'user_id is not null' ], :order => [ :endtime.desc ], :limit => 50)
    @games_played_user_links = true
    @games_played_title = "Last #{@games_played.size} games played"
    haml :last_games_played
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end
