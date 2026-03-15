require 'tournament_times'

class News < ActiveRecord::Base
  def self.seed_news
    if $tournament_signupstarttime
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
end
