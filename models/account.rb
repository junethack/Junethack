
class Account                           #join model
        include DataMapper::Resource

        belongs_to :user,       :key => true
        belongs_to :server,     :key => true

	
        property :name,         String
        property :verified,     Boolean, :default => false

	def get_games
		self.server.games.select{|game| game.name == self.name}
	end
end

