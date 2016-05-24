class Clan
    include DataMapper::Resource
    property :admin,    Json
    has n, :users
    property :name,     String, :key => true, :length => 1...30
    property :invitations,     Json, :default => []

    validates_format_of :name, :with => /^\w*$/, :message => "Clan name may only contain a-z, A-Z and 0-9"
    def get_invitation_response invitation
        if index = self.invitations.index{|i| i['token'] == invitation['token'] and i['account'] == invitation['account']}
            self.invitations.delete_at index
            self.save
            return true
        end
        return false
    end
    def get_admin
        return User.get(self.admin[0])
    end
end
