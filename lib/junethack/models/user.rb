require 'dm-migrations/migration_runner'
class User
    include DataMapper::Resource

    has n, :scoreentries
    has n, :individualtrophies
    has n, :accounts
    has n, :servers, :through => :accounts
    has n, :games, :through => :servers

    property :id,       Serial
    property :login,    String
    property :hashed,   String, :length => 64
    property :salt,     String, :length => 64
   
    property :clan,     String

    property :created_at, DateTime
    property :updated_at, DateTime
 
    validates_format_of :login, :with => /^\w*$/, :message => "login name may only contain a-z, A-Z, 0-9 and _"

    def password=(pw)
        self.salt = Digest::SHA256.hexdigest("#{rand}") #generate random hash
        self.hashed = User.encrypt(pw, self.salt)
    end 

    def self.encrypt(pw, salt)
        Digest::SHA256.hexdigest(pw + salt)
    end 
    
    def self.authenticate(login, pass)
        u = User.first(:login => login)
        return false unless u
        User.encrypt(pass, u.salt) == u.hashed ? u : false
    end

    # get all played games by this user
    def games
        Game.all(:user_id => self.id)
    end

    # count of played games by this user
    def games_count
        Game.count(:user_id => self.id)
    end
    # count of start scummed games by this user
    def start_scummed_games_count
        StartScummedGame.count(:user_id => self.id)
    end
    # count of start scummed games by this user
    def junk_games_count
        JunkGame.count(:user_id => self.id)
    end

    def ascensions
        self.accounts.map{|account| account.get_ascensions}.flatten
    end

    def most_variant_trophies_count
        (repository.adapter.select "SELECT count(1) from ("+variant_trophy_combinations_user_sql+");", self.id)[0]
    end

    # user.to_i will return user.id or 0 if user == nil
    def to_i
        self.id
    end

    def User.max_created_at
        repository.adapter.select "select strftime('%s',max(created_at)) from users"
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

end
