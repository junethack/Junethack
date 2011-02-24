require 'rubygems'
require 'sinatra'
require 'database'
require 'haml'

enable :sessions

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

post "/login" do
    
    if user = User.authenticate(params["username"], params["password"])
        session['user_id'] = user.id
        puts "Id is #{user.id}"
        session["messages"] 
        redirect "/home"
    else
        session["errors"] = ["Could not log in"]
        redirect "/"
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
