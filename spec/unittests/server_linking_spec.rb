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

      game = Game.new(name: 'player', starttime: 123456, version: '3.4.3')
      nao = Server.new(url: 'http://nethack.alt.org/')
      nao.dumplog_link(game).should == "http://alt.org/nethack/userdata/p/player/dumplog/123456.nh343.txt"

      game = Game.new(:name => 'player', :endtime => 123456)
      un_nethack_nu = Server.new(url: 'http://un.nethack.nu/')
      un_nethack_nu.dumplog_link(game).should == "https://un.nethack.nu/user/player/dumps/us/player.123456.txt.html"

      game = Game.new(:name => 'player', :starttime => 123456)
      grunthack = Server.new(url: 'http://grunthack.org/')
      grunthack.dumplog_link(game).should == "http://grunthack.org/userdata/p/player/dumplog/123456.gh020.txt"
    end
  end

  context "given a game and a user" do
    it "should return the link to the user's server home page" do
      pending "not yet implemented"
    end
  end
end
