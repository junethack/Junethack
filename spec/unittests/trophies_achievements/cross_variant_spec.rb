require 'spec_helper'

describe Individualtrophy do

  before :each do
    clean_database
    $user = User.create(:login => "test_user")
    Trophy.create trophy: :test_achievement, text: 'an achievement', icon: :icon
  end

  it "should add user unique cross variant achievements" do
    expect(Individualtrophy.count).to eq 0

    # add achievement
    Individualtrophy.add($user.id, :test_achievement, "test_achievement.png")
    expect(Individualtrophy.count).to eq 1

    # only one achievement per user
    Individualtrophy.add($user.id, :test_achievement, "test_achievement.png")
    expect(Individualtrophy.count).to eq 1
  end

  it "should add Events for cross variant achievements" do
    expect(Event.count).to eq 0

    # add achievement
    Individualtrophy.add($user.id, :test_achievement, "test_achievement.png")
    expect(Event.count).to eq 1

    # only one achievement per user
    Individualtrophy.add($user.id, :test_achievement, "test_achievement.png")
    expect(Event.count).to eq 1

    expect(Event.first.text).to eq 'Achievement "an achievement" unlocked by test_user!'
  end
end

describe Game,"saving of cross variant achievements" do
 
  before :each do
    clean_database
    $user = User.create(:login => "test_user")
    $server = Server.create(name: 'server_variant', url: "http://example.ignore/")
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
    params = { server_id: $server.id, version: '', achieve: "0x800", endtime: 1000, death: 'ascended', turns: 1023 }
    half_variants_count = $variant_order.count / 2

    expect(Individualtrophy.count).to eq 0
    expect(Event.count).to eq 0

    Game.create(params)
    repository.adapter.execute "UPDATE games SET version= 'v'||id"
    update_games
    expect(Individualtrophy.count).to eq 4
    expect(Individualtrophy.all.map(&:trophy).sort).to eq ["anti_stoner_1", "ascended_variants_1", "globetrotter_1", "sightseeing_tour_1"]
    expect(Event.count).to eq 4
    expect(Event.all.map(&:text).sort).to eq(
      ['Achievement "Ascended one variant" unlocked by test_user!',
       'Achievement "Sightseeing Tour: finish a game in one variant" unlocked by test_user!',
       'Achievement "Anti-Stoner: defeated Medusa in one variant" unlocked by test_user!',
       'Achievement "Globetrotter: get a trophy in one variant" unlocked by test_user!'].sort
    )

    Game.create(params)
    repository.adapter.execute "UPDATE games SET version= 'v'||id"
    update_games
    expect(Individualtrophy.all.map(&:trophy)).to include "anti_stoner_2"
    expect(Individualtrophy.count).to eq 8
    expect(Event.all.map(&:text)).to include 'Achievement "Anti-Stoner: defeated Medusa in two variants" unlocked by test_user!'
    expect(Event.count).to eq 8
  end
end
