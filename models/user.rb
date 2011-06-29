require 'scrypt'

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

    def self.authenticate(login, pass)
        u = User.first(:login => login)
        return false unless u
        User.encrypt(pass, u.salt) == u.hashed ? u : false
    end

    def games
        self.accounts.map{|account| account.get_games}.flatten
    end
end

