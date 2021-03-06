require 'spec_helper'

require 'trophyscore'
require 'userscore'

describe Game do
  it "removes the version info from variants that often change their version number" do
    Game.new(version: 'UNH-4.1.1',
             user_id: 1,
             server_id: 1,
             death: 'ascended').save!

    expect(Game.first(version: 'UNH-4.1.1')).to be_nil
    expect(Game.first(version: 'unh')).to be
  end

  it "does not change the version info from variants without development" do
    Game.new(version: '3.4.3',
             user_id: 1,
             server_id: 1,
             death: 'ascended').save!

    expect(Game.first(version: '3.4.3')).to be
  end

  describe 'for not unique version info' do
    it 'heuristically determines the version info from the server' do
      server = Server.new(name: 'server_variant').tap(&:save!)
      Game.new(server_id: server.id, version: 'unknown', death: 'ascended').save!
      expect(Game.first(version: 'variant')).to be
    end
  end
end

describe Game, ".defeated_medusa?" do
  it "returns true if Medusa was killed" do
    # standard xlogfile method
    g = Game.new(:version => '3.4.3', :death => '', :achieve => "0x800")
    expect(g.defeated_medusa?).to be true

    g = Game.new(:version => '3.4.3', :death => '', :achieve => "0x1802")
    expect(g.defeated_medusa?).to be true

    # event method
    g = Game.new(:version => '3.4.3', :death => '', :event => "4096")
    expect(g.defeated_medusa?).to be true

    g = Game.new(:version => '3.4.3', :death => '', :event => "65535")
    expect(g.defeated_medusa?).to be true
  end

  it "returns false if Medusa was not killed" do
    # standard xlogfile method
    g = Game.new(:version => '3.4.3', :death => '', :achieve => "0x0")
    expect(g.defeated_medusa?).to be_falsey

    # event method
    g = Game.new(:version => '3.4.3', :death => '', :event => "0")
    expect(g.defeated_medusa?).to be_falsey
  end
end

describe Game, ".ascended_heaven_or_hell?" do
  it "returns correct result if ascended in Heaven or Hell" do
    g = Game.new(:version => '3.4.3', :death => 'ascended', :mode => "debug")
    expect(g.ascended_heaven_or_hell?).to be false

    g = Game.new(:version => '3.4.3', :death => 'killed', :mode => "hoh")
    expect(g.ascended_heaven_or_hell?).to be false

    g = Game.new(:version => '3.4.3', :death => 'ascended', :mode => "hoh")
    expect(g.ascended_heaven_or_hell?).to be true

    g = Game.new(:version => '3.4.3', :death => 'defied the gods', :mode => "hoh")
    expect(g.ascended_heaven_or_hell?).to be true
  end
end

describe Game, ".mini_croesus?" do
  it "works in not ascended games" do
    g = Game.new(version: '3.4.3', death: 'ascended', gold: "24999")
    expect(g.mini_croesus?).to be false

    g = Game.new(version: '3.4.3', death: 'ascended', gold: "25001")
    expect(g.mini_croesus?).to be true

    g = Game.new(version: '3.4.3', death: 'killed',   gold: "25001")
    expect(g.mini_croesus?).to be true

    g = Game.new(version: '3.4.3', death: 'escaped',  gold: "25000")
    expect(g.mini_croesus?).to be true
  end
end

describe Game, ".better_than_croesus?" do
  it "works in not ascended games" do
    g = Game.new(version: '3.4.3', death: 'ascended', gold: "199999")
    expect(g.better_than_croesus?).to be false

    g = Game.new(version: '3.4.3', death: 'ascended', gold: "200001")
    expect(g.better_than_croesus?).to be true

    g = Game.new(version: '3.4.3', death: 'killed',   gold: "200001")
    expect(g.better_than_croesus?).to be true

    g = Game.new(version: '3.4.3', death: 'escaped',  gold: "200000")
    expect(g.better_than_croesus?).to be true
  end
end
