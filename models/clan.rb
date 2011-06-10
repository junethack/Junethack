class Clan
	include DataMapper::Resource
	has n, :accounts
	property :name, 	Serial
	property :invitations, 	Json

	def invite user	
		if acc = Account.first(:name => user)
			chars = ('a'..'z').to_a
			invitation = {'status' => 'open', 'user' => user, 'token' => (0..30).map{ chars[rand 26] }}
			acc.invite invitation
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
				
