class Clan
	include DataMapper::Resource
	belongs_to :creator,	'Account'
	has n, :accounts
	property :name, 	String, :key => true
	property :invitations, 	Json

	def invite user	
		if acc = Account.first(:name => user)
			chars = ('a'..'z').to_a
			invitation = {'clan_id' => self.name, 'status' => 'open', 'user' => user, 'token' => (0..30).map{ chars[rand 26] }.join}
			acc.invite invitation
			self.invitations ||= []
			self.invitations.push invitation
			self.save
		end
	end
			

	def get_invitation_response invitation
		if index = self.invitations.index{|i| i['token'] == invitation['token'] and i['account'] == invitation['account']}
			
			if acc = Account.get(invitation['user'])
				if invitation['status'] == 'accept'
					acc.clan = self

					
					self.accounts.push acc
				end
				acc.invitations.reject!{|i| i['token'] == invitation['token']}
				acc.save

			end
			self.invitations.delete_at index
			self.save
		end
	end
	
end		
				
