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

    def ascensions
        self.accounts.map{|account| account.get_ascensions}.flatten
    end
end
DataMapper::MigrationRunner.migration(1, :add_clan_to_users) do
    up do
        execute 'ALTER TABLE users ADD clan string;'
    end
end
DataMapper::MigrationRunner.migration(2, :update_users_clan) do
    up do
        execute 'UPDATE USERS SET clan = (SELECT clan_name FROM accounts WHERE clan_name IS NOT NULL AND user_id = id);'
    end
end
