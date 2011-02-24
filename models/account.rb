class Account #join model
    include DataMapper::Resource

    belongs_to :user,   :key => true
    belongs_to :server, :key => true
    belongs_to :clan,   :required => false
    
    property :name,        String
    property :verified,    Boolean, :default => false
    property :invitations, Json

    def get_games
        self.server.games.select{|game| game.name == self.name}
    end

    def invite invitation
        self.invitations ||= []
        self.invitations.push invitation
        self.save
    end

    def respond_invite invitation, accept
        if clan = Clan.first(:name => invitation['clan_id'])
            invitation['status'] = accept ? 'accept' : 'decline'
            clan.get_invitation_response invitation
        end
    end    
end

