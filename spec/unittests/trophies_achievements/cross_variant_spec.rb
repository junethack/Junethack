require 'spec_helper'

describe Individualtrophy do

  before :each do
    clean_database
    $user = User.create(:login => "test_user")
  end

  it "should add user unique cross variant achievements" do
    expect(Individualtrophy.count).to eq 0

    # add achievement
    Individualtrophy.add($user.id, nil, :test_achievement, "test_achievement.png")
    expect(Individualtrophy.count).to eq 1

    # only one achievement per user
    Individualtrophy.add($user.id, nil, :test_achievement, "test_achievement.png")
    expect(Individualtrophy.count).to eq 1
  end

  it "should add Events for cross variant achievements" do
    expect(Event.count).to eq 0

    # add achievement
    Individualtrophy.add($user.id, "test_achievement", :test_achievement, "test_achievement.png")
    expect(Event.count).to eq 1

    # only one achievement per user
    Individualtrophy.add($user.id, "test_achievement", :test_achievement, "test_achievement.png")
    expect(Event.count).to eq 1

    expect(Event.first.text).to eq 'Achievement "test_achievement" unlocked by test_user!'
  end
end

describe Game,"saving of cross variant achievements" do
 
  before :each do
    clean_database
    $user = User.create(:login => "test_user")
    $server = Server.create(url: "http://example.ignore/")
  end

  # Games are saved first without user_id, the scoring calculation only triggers
  # on updates
  def update_games
    Game.all.each {|g|
      g.user_id = $user.id
      g.save
    }
  end

  it "should correctly create cross variant achievements" do
    params = { server_id: $server.id, achieve: "0x800", endtime: 1000, death: 'ascended', turns: 1023 }

    expect(Individualtrophy.count).to eq 0
    expect(Event.count).to eq 0

    Game.create(params.merge version: 'v1')
    Game.create(params.merge version: 'v2')
    Game.create(params.merge version: 'v3')
    Game.create(params.merge version: 'v4')
    update_games
    expect(Individualtrophy.count).to eq 0
    expect(Event.count).to eq 0

    Game.create(params.merge version: 'v5')
    update_games # 1/2 cross variant achievements
    expect(Individualtrophy.count).to eq 4
    expect(Event.count).to eq 4

    Game.create(params.merge version: 'v6')
    Game.create(params.merge version: 'v7')
    Game.create(params.merge version: 'v8')
    Game.create(params.merge version: 'v9')
    Game.create(params.merge version: 'v10')
    update_games
    expect(Individualtrophy.count).to eq 4
    expect(Event.count).to eq 4

    Game.create(params.merge version: 'v11')
    update_games # full and 1/2 cross variant achievements
    expect(Individualtrophy.count).to eq 8
    expect(Event.count).to eq 8
  end
end
