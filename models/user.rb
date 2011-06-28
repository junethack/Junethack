class User
    include DataMapper::Resource

    has n, :accounts
    has n, :servers, :through => :accounts

    property :id,     Serial
    property :login,  String
    property :hashed, String, :length => 200

    def password=(pw)
        self.hashed = SCrypt::Password.create(pw, :max_time => 0.5)
    end 

    def self.authenticate(login, pass)
        u = User.first(:login => login)
        return false unless u
        (SCrypt::Password.new(u.hashed) == pass) ? u : false
    end

    def games
        self.accounts.map{|account| account.get_games}.flatten
    end
end

