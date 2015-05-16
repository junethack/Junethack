require 'spec_helper'

require 'datamapper'
require 'models/game'
require 'models/server'

describe 'server linking helper methods' do
  context "given a game and a server" do
    it "should return the download link for the game's dumplog" do
      game = Game.new()
      dumplog_less_server = Server.new(:id => '1')
      dumplog_less_server.dumplog_link(game).should be_nil

      game = Game.new(:name => 'player', :starttime => 123456)
      nao = Server.new(:url => 'nethack.alt.org')
      nao.dumplog_link(game).should == "http://alt.org/nethack/userdata/p/player/dumplog/123456.nh343.txt"

      game = Game.new(:name => 'player', :endtime => 123456)
      un_nethack_nu = Server.new(:url => 'un.nethack.nu')
      un_nethack_nu.dumplog_link(game).should == "https://un.nethack.nu/user/player/dumps/us/player.123456.txt.html"

      game = Game.new(:name => 'player', :starttime => 123456)
      grunthack = Server.new(:url => 'grunthack.org')
      grunthack.dumplog_link(game).should == "http://grunthack.org/userdata/p/player/dumplog/123456.gh020.txt"

      game = Game.new(:name => 'player', :version => '3.6.0', :starttime => 123456)
      acehack_de = Server.new(:url => 'acehack.de')
      acehack_de.dumplog_link(game).should == "http://acehack.de/userdata/player/dumplog/123456"

      game_vanilla = Game.new(:name => 'player', :version => '3.4.3', :starttime => 123456)
      acehack_de.dumplog_link(game_vanilla).should == "http://acehack.de/userdata/player/nethack/dumplog/123456"
    end
  end

  context "given a game and a user" do
    it "should return the link to the user's server home page" do
      pending "not yet implemented"
    end
  end
end
