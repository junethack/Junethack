require 'rubygems'
require 'sinatra'
require 'database'
require 'haml'

enable :sessions

get "/" do
	haml :index
end

post "/login" do
	puts "got params #{params.inspect}"
	
	if user = User.authenticate(params["username"], params["password"])
		session['user_id'] = user.id
		puts "Id is #{user.id}"
		redirect "/home"
	else
		redirect "/"
	end
end
	
get "/register" do
	
	haml :register
end

get "/home" do
	puts "Id is #{session['user_id']}"	
	redirect "/" and return unless session['user_id']
	@user = User.get(session['user_id'])
	@games = @user.games	
	haml :home
end

post "/create" do
	errors = []
	errors.push("password and confirmation do not match") if params["confirm"] != params["password"]
	errors.push("username does already exist") if User.first(:name => params[:username])
	puts errors.inspect
	redirect "/register", :params => {:messages => errors} and return unless errors.empty?
	puts params.inspect
	user = User.new(:login => params["username"])
	user.password = params["password"]
	if user.save
		redirect "/", :params => {:messages => ["Registration successful. Please log in."]}
	else
		redirect "/register", :params => {:messages => ["Could not create account."]}
	end
end	
