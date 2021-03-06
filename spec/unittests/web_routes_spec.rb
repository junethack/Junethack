require 'spec_helper'

require 'sinatra_server'
require 'rack/test'

describe 'the Junethack server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before :all do
    clean_database
  end

  it "should render empty pages" do
    ["/", "/trophies", "/users", "/about", "/rules", "/clans",
     "/scoreboard", "/player_scoreboard", "/trophy_scoreboard",
     "/servers", "/ascensions",
     "/deaths", "/games", "/activity", "/junethack.rss"].each do |url|
      get url
      last_response.should be_ok
      last_response.body.should include("Junethack")
    end
  end

end


# get "/home"
# get "/register"
# get "/login"
# get "/logout"
# get "/user/:name"
# get "/user_id/:id"
# get "/server/:name"
# get "/server/:name/all"
# get "/respond/:server_id/:token"
# get "/clan/disband/:name"
# get "/clan/:name"
# get "/leaveclan/:server"
# get "/scores/:name"
