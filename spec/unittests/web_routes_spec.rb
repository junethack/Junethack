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
    Trophy.seed_trophies
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

  describe "GET /ascensions" do
    let(:server) { Server.create(url: 'http://server.test') }
    let(:user) { User.create!(login: 'testplayer', ) }
    let(:ascended_game) { Game.create!(version: '3.4.3', server:, user:, death: 'ascended', points: 123) }
    let(:non_ascended_game) { Game.create!(version: '3.4.3', server:, user:, death: 'died', points: 234) }

    before do
      expect(ascended_game).to be_valid
      expect(non_ascended_game).to be_valid
    end

    it "displays only ascended games" do
      get "/ascensions"

      expect(last_response).to be_ok
      expect(last_response.body).to include('ascended')
      expect(last_response.body).not_to include('died')
      expect(last_response.body).to include('123')
      expect(last_response.body).not_to include('234')
      expect(last_response.body).to include('Last 1 ascended games')
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
