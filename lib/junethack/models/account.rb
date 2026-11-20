class Account < ActiveRecord::Base
    # Composite primary key (user_id, server_id) is read from the database schema.

    belongs_to :user
    belongs_to :server

    validates :name, format: { with: /\A\w*\z/, message: "Account name may only contain a-z, A-Z and 0-9" }

    def get_games
        self.server.games.select{|game| game.name == self.name}
    end

    def get_ascensions
        self.server.games.select{|game| game.name == self.name &&
                                        game.death == 'ascended'}
    end
end
