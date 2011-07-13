require 'rubygems'
require 'cgi'
require 'bundler/setup'
require 'sinatra'
require 'database'
require 'haml'
require 'fetch_games'
require 'rufus/scheduler'
require 'trophy_calculations'
require 'userscore'

#enable :sessions
use Rack::Session::Pool #fix 4kb session dropping
# Scheduler: fetch game data every 15 minutes
scheduler = Rufus::Scheduler.start_new
scheduler.cron('*/15 * * * *') { fetch_all }

before do
    @user = User.get(session['user_id'])
    @logged_in = @user.nil?
    @messages = session["messages"] || []
    @errors = session["errors"] || []
    puts "got #{@messages.length} messages"
    puts "and #{@errors.length} errors"
    puts "#{@errors.inspect}"
    session["messages"] = []
    session["errors"] = []
end

get "/" do
    @show_banner = true
    haml :splash
end

get "/login" do
    @show_banner = true
    haml :login
end

get "/logout" do
    session['user_id'] = nil
    session['messages'] = ["Logged out"]

    redirect "/" and return
end

get "/about" do
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
    @show_banner = true
    haml :rules
end

get "/home" do
    redirect "/" and return unless session['user_id']

    @userscore = UserScore.new session['user_id']

    @user = User.get(session['user_id'])
    @games = Game.all(:user_id => @user.id, :order => [ :endtime.desc ])
    haml :home
end

post "/add_server_account" do
    redirect "/" and return unless session['user_id']

    # TODO automatically do verification and inform user if it fails
    server = Server.get(params[:server])
    account = Account.create(:user => User.get(session['user_id']), :server => server, :name => params[:user], :verified => true)
    # set user_id on all already played games
    Game.all(:name => params[:user], :server => server).update(:user_id => session['user_id'])

    session['errors'] = "Couldn't create account!" unless account
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
    if user.save
        session['messages'] = "Registration successful. Please log in."
        redirect "/"
    else
        session['errors'] = "Could not register account"
        redirect "/register"
    end
end


get "/clan/:name" do
    @clan = Clan.get(params[:name])   
    if @clan
        puts "Invitations: #{@clan.invitations.inspect}"
        @admin = @clan.get_admin
        haml :clan
    else
        session['errors'] << "Could not find clan with id #{params[:name].inspect}"
        redirect "/home"
    end
end

post "/clan" do
    acc = Account.first(:user_id => @user.id, :server_id => params[:server].to_i)
    if acc
        clan = Clan.create(:name => params[:clanname], :admin => [acc.user.id, acc.server.id])
        acc.clan = clan
        acc.save
        @messages << "Successfully created clan #{params[:clanname]}"
        puts CGI.escape(acc.clan.name)
        redirect "/clan/" + CGI.escape(acc.clan.name)
    else 
        @errors << "Could not find your account on this server"
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
    @highest_density_users = best_sustained_ascension_rate(@u.id)
    haml :user_scores
end

get "/scoreboard" do
    @last_10_games = get_last_games
    @most_ascended_users = most_ascensions_users
    @highest_density_users = best_sustained_ascension_rate
    haml :scoreboard
end


helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end
