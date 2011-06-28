require 'rubygems'
require 'sinatra'
require 'database'
require 'haml'
require 'fetch_games'
require 'rufus/scheduler'

enable :sessions

# Scheduler: fetch game data every hour (xx:00)
scheduler = Rufus::Scheduler.start_new
scheduler.cron('0 * * * *') { fetch_all }

before do
    @messages = session["messages"] || []
    @errors = session["errors"] || []
    puts "got #{@messages.length} messages"
    puts "and #{@errors.length} errors"
    session["messages"] = []
    session["errors"] = []
end

get "/" do
    haml :splash
end

get "/login" do
    haml :login
end

get "/about" do
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
    
    haml :register
end

get "/home" do
    redirect "/" and return unless session['user_id']
    @user = User.get(session['user_id'])
    @games = @user.games    
    haml :home
end

post "/create" do
    errors = []
    errors.push("password and confirmation do not match") if params["confirm"] != params["password"]
    errors.push("username does already exist") if User.first(:name => params[:username])
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

# This is just for testing, but hey, it works.
get "/scores/:name" do |name|
    result = "<h1>Scores for #{ name }</h1>"
    User.first(:name => name).accounts.each do |acc|
        result += "<h2>#{ acc.server.name }</h2>\n<ul>"
        acc.server.games.each do |game|
            next if game.name != acc.name
            entry = [:name, :role, :race, :gender, :align, :points, :death] \
                    .map{ |s| game.attributes[s] } \
                    .join ', '
            result += "<li>#{entry}</li>\n"
        end
        result += "</ul>"
    end
    result
end

