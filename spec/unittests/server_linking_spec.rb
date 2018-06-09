require 'spec_helper'

require 'data_mapper'
require 'models/game'
require 'models/server'

describe 'server linking helper methods' do
  context "given a game and a server" do
    it "should return the download link for the game's dumplog" do
      game = Game.new()
      dumplog_less_server = Server.new(id: '1', url: "http://example.ignore/")
      dumplog_less_server.dumplog_link(game).should be_nil

      game = Game.new(name: 'player', starttime: 123456, version: '3.6.1')
      nao = Server.new(url: 'http://nethack.alt.org/')
      expect(nao.dumplog_link(game)).to eq 'https://s3.amazonaws.com/altorg/dumplog/player/123456.nh361.txt'

      game = Game.new(:name => 'player', :starttime => 123456)
      grunthack = Server.new(url: 'http://grunthack.org/')
      grunthack.dumplog_link(game).should == "http://grunthack.org/userdata/p/player/dumplog/123456.gh020.txt"
    end

    it 'returns a link to the european or american server of hardfought.org' do
      hdf = Server.new(name: 'xxx_unh', url: 'https://www.hardfought.org')
      game = Game.new(name: 'player', starttime: 123456, server: hdf, version: '')
      expect(hdf.dumplog_link(game)).to eq 'https://www.hardfought.org/userdata/p/player/un531/dumplog/123456.un531.txt.html'

      hdf = Server.new(name: 'xxx_unh', url: 'https://eu.hardfought.org')
      game = Game.new(name: 'player', starttime: 123456, server: hdf, version: '')
      expect(hdf.dumplog_link(game)).to eq 'https://eu.hardfought.org/userdata/p/player/un531/dumplog/123456.un531.txt.html'
    end
  end

  context "given a game and a user" do
    it "should return the link to the user's server home page" do
      skip "not yet implemented"
    end
  end
end
