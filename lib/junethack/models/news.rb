require 'dm-migrations'
require 'dm-migrations/migration_runner'
require 'tournament_times'

class News
    include DataMapper::Resource

    property :id,         Serial
    property :html,       String, :required => true
    property :text,       String # dummy, only used for compatibility with Event
    property :url,        String # dummy, only used for compatibility with Event

    property :created_at, DateTime
    property :updated_at, DateTime
end

DataMapper::MigrationRunner.migration(1, :create_announcements) do
  up do
    return unless $tournament_signupstarttime

    dates = [
      ["<a href='/register'>Registration for Junethack #{Date.today.year}</a> has opened!", $tournament_signupstarttime],
      ["Junethack #{Date.today.year} has started! Happy splatting!",  $tournament_starttime],
      ["Junethack #{Date.today.year} has ended! Thanks for playing!", $tournament_endtime],
      # 10 minutes after the end of the tournament
      ["The <a href='/post_tournament_statistics'>boring post tournament statistics</a> page is up", $tournament_endtime+60*10],
    ]
    dates.each {|news, date|
      News.create html: news, created_at: DateTime.strptime(date.to_s,'%s')
    }
  end
end
