class Account #join model
    include DataMapper::Resource

    belongs_to :user,   :key => true
    belongs_to :server, :key => true

    property :name,        String
    property :verified,    Boolean, :default => false
    validates_format_of :name, :with => /^\w*$/, :message => "Account name may only contain a-z, A-Z and 0-9"

    def get_games
        self.server.games.select{|game| game.name == self.name}
    end

    def get_ascensions
        self.server.games.select{|game| game.name == self.name &&
                                        game.death == 'ascended'}
    end
end

