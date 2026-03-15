# variant-specific user trophies
class Scoreentry < ActiveRecord::Base
    self.primary_keys = :user_id, :variant, :trophy

    belongs_to :user
end

# cross-variant user trophies
class Individualtrophy < ActiveRecord::Base
    self.primary_keys = :user_id, :trophy

    belongs_to :user

    def Individualtrophy.add(user_id, trophy, icon)
      # check for existence
      c = Individualtrophy.find_by(user_id: user_id,
              trophy: trophy,
              icon: icon)
      # achievement doesn't exist yet, create it
      if not c then
        Individualtrophy.create(user_id: user_id,
                                trophy: trophy,
                                icon: icon)
        text = Trophy.find_by(trophy: trophy).text
        user = User.find(user_id).login
        event_text = "Achievement \"#{text}\" unlocked by #{user}!"

        sightseeing_tour = /Sightseeing Tour: finish a game in (one|two|three|four) variants?/
        globetrotter = /Globetrotter: get a trophy in (one|two|three|four) variants?/
        medusa = /Anti-Stoner: defeated Medusa in one variant/
        ascender = /Diversity Ascender: Ascended one variant/
        spam_protection = text =~ sightseeing_tour || text =~ globetrotter || text =~ medusa || text =~ ascender

        if spam_protection
          puts "Spam protection for #{event_text}"
        else
          Event.create(text: event_text)
        end
      end
    end
end

# competition clan trophies
class ClanScoreEntry < ActiveRecord::Base
    self.primary_keys = :clan_name, :trophy

    belongs_to :clan, foreign_key: :clan_name, primary_key: :name
end

# competition clan trophies history
class ClanScoreHistory < ActiveRecord::Base
    belongs_to :clan, foreign_key: :clan_name, primary_key: :name
end

# variant-specific competition user trophies
class CompetitionScoreEntry < ActiveRecord::Base
    self.primary_keys = :user_id, :trophy, :variant

    belongs_to :user
end
