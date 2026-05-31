require 'digest/md5'

class Clan < ActiveRecord::Base
  self.primary_key = :name

  serialize :admin, JSON
  serialize :invitations, JSON

  has_many :users, foreign_key: :clan_name, primary_key: :name

  validates :name, format: {
    with: /\A[a-zA-Z0-9_.-]+\z/, message: "Clan name may only contain a-z, A-Z, -, _, . and 0-9"
  }
  validates :name, uniqueness: { message: "Clan name already exists" }

  def get_invitation_response invitation
    if index = self.invitations.index{|i| i['token'] == invitation['token'] and i['account'] == invitation['account']}
      self.invitations.delete_at index
      self.save
      return true
    end
    return false
  end

  def get_admin
    return User.find(self.admin[0])
  end

  def gravatar_link
    hash = gravatar || Digest::MD5.hexdigest(name)

    "https://www.gravatar.com/avatar/#{hash}?s=200&d=retro"
  end
end
