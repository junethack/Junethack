require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'database'
require 'haml'
require 'fetch_games'
require 'rufus/scheduler'
require 'trophy_calculations'
require 'userscore'

enable :sessions

# Scheduler: fetch game data every hour (xx:00)
scheduler = Rufus::Scheduler.start_new
scheduler.cron('*/15 * * * *') { fetch_all }

before do
    @user = User.get(session['user_id'])
    @logged_in = @user.nil?
    @messages = session["messages"] || []
    @errors = session["errors"] || []
    puts "got #{@messages.length} messages"
    puts "and #{@errors.length} errors"
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
