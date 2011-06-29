class User
    include DataMapper::Resource

    has n, :accounts
    has n, :servers, :through => :accounts

    property :id,     Serial
    property :login,  String
    property :hashed, String, :length => 64
    property :salt,   String, :length => 64

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

    def games
        self.accounts.map{|account| account.get_games}.flatten
    end

    # Gets last 10 games for all accounts.
    # Ordered by time.
    def get_10_last_games
        ordered_games = [ ]
        num_games = 0
        games.sort_by{|et| et.endtime}.each do |game|
            ordered_games.push(game)
            num_games += 1
            break unless num_games < 10
        end
        ordered_games.reverse
    end
end

