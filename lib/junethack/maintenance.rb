require 'rubygems'
require 'cgi'
require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'helper'
require 'time'
require 'logger'

set :root, "#{Dir.pwd}"

$not_numbers = ["NaN", "infinite", "\u2135\u2080"]

def not_a_number
  $not_numbers[Process.pid % $not_numbers.size]
end

class User
  def User.count
    not_a_number
  end
end

class Game
  def Game.count(ignore)
    not_a_number
  end
end

get "/*" do
    @logged_in = true
    @messages = []
    @errors = []
    @show_banner = true
    status 503
    haml :maintenance
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end
