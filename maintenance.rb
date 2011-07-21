require 'rubygems'
require 'cgi'
require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'helper'
require 'time'
require 'logger'

class User
def User.count
    "infinite"
end
end

class Game
def Game.count
    "infinite"
end
end

get "/*" do
    @logged_in = true
    @messages = []
    @errors = []
    @show_banner = true
    haml :maintenance
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end
