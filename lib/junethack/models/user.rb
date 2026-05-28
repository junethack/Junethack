class User < ActiveRecord::Base
    has_many :scoreentries
    has_many :individualtrophies
    has_many :accounts
    has_many :servers, through: :accounts
    belongs_to :clan, foreign_key: :clan_name, primary_key: :name, optional: true

    serialize :invitations, JSON

    before_save :default_invitations

    validates :login, format: { with: /\A\w+\z/, message: "login name may only contain a-z, A-Z, 0-9 and _" }

    def default_invitations
        self.invitations ||= []
    end

    def password=(pw)
        self.salt = Digest::SHA256.hexdigest("#{rand}") #generate random hash
        self.hashed = User.encrypt(pw, self.salt)
    end

    def self.encrypt(pw, salt)
        Digest::SHA256.hexdigest(pw + salt)
    end

    def self.authenticate(login, pass)
        u = User.find_by(login: login)
        return false unless u
        User.encrypt(pass, u.salt) == u.hashed ? u : false
    end

    # get all played games by this user
    def games
        Game.where(user_id: self.id)
    end

    # count of played games by this user
    def games_count
        Game.where(user_id: self.id).count
    end
    # count of start scummed games by this user
    def start_scummed_games_count
        StartScummedGame.where(user_id: self.id).count
    end
    # count of start scummed games by this user
    def junk_games_count
        JunkGame.where(user_id: self.id).count
    end

    def ascensions
        self.accounts.map{|account| account.get_ascensions}.flatten
    end

    def most_variant_trophies_count
        (ActiveRecord::Base.connection.select_values("SELECT count(1) from ("+variant_trophy_combinations_user_sql+");", "SQL", [self.id]))[0]
    end

    # user.to_i will return user.id or 0 if user == nil
    def to_i
        self.id
    end

    def User.max_created_at
      ActiveRecord::Base.connection.select_values('SELECT EXTRACT(EPOCH FROM MAX(created_at))::int FROM users')
    end

    def display_game_statistics
        n = self.games_count
        s = (n == 1) ? "" : "s"
        game = "#{n} Game#{s} Played"
        n = self.junk_games_count
        s = (n == 1) ? "" : "s"
        game += " | #{n} Junk Game#{s}" if n > 0
        n = self.start_scummed_games_count
        s = (n == 1) ? "" : "s"
        game += " | #{n} Game#{s} Start Scummed" if n > 0
        return game
    end

    def respond_invite invitation, accept
        if clan = Clan.find_by(name: invitation['clan_id'])
            invitation['status'] = accept ? 'accept' : 'decline'
            return clan.get_invitation_response invitation
        end
    end
end
