class Account #join model
    include DataMapper::Resource

    belongs_to :user,   :key => true
    belongs_to :server, :key => true
    belongs_to :clan,   :required => false
    
    property :name,        String
    property :verified,    Boolean, :default => false
    property :invitations, Json
    validates_format_of :name, :with => /^\w*$/, :message => "Account name may only contain a-z, A-Z and 0-9"
    before :save do
        self.invitations ||= []
    end

    def get_games
        self.server.games.select{|game| game.name == self.name}
    end

    def get_ascensions
        self.server.games.select{|game| game.name == self.name &&
                                        game.death == 'ascended'}
    end

    def respond_invite invitation, accept
        if clan = Clan.first(:name => invitation['clan_id'])
            invitation['status'] = accept ? 'accept' : 'decline'
            return clan.get_invitation_response invitation 
        end
    end    
end

