require 'spec_helper'

require 'fetch_games'
require 'sync'

describe 'fetching games' do
  context "given a server which doesn't return a last-modified header" do

    before :each do
      @fetch_logger = Logger.new("/dev/null")
      @fetch_logger_error = Logger.new("/dev/null")
      @stop_fetching_games = "stop_fetching_games"

      Server.create(:name => "test_server")

      # mock out fetched headers
      def XLog.fetch_header(url)
       return "HTTP/1.1 200 OK\n"
      end
    end

    it "should not crash when fetching new games" do
      fetch_all
      # used to crash the second time fetch_all was called
      fetch_all
    end
  end

end
