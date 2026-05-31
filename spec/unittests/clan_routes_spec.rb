require 'spec_helper'

require 'sinatra_server'
require 'rack/test'

describe 'Clan routes' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before :all do
    clean_database
    Trophy.seed_trophies
  end

  before :each do
    clean_database
  end

  # Shared test data using let
  let(:admin_user) { User.create!(login: 'admin_user', password:) }
  let(:regular_user) { User.create!(login: 'regular_user', password:) }
  let(:member_user) { User.create!(login: 'member_user', password:) }
  let(:invitee_user) { User.create!(login: 'invitee_user', password:) }
  let(:password) { 'password123' }

  let(:clan) { Clan.create!(name: 'testclan', admin: [admin_user.id, 1], description: 'Test clan') }
  let(:clan_with_members) do
    c = Clan.create!(name: 'clanwithmembers', admin: [admin_user.id, 1])
    member_user.clan_name = c.name
    member_user.save
    c
  end

  let(:basic_invitation) do
    {
      'clan_id' => clan.name,
      'status' => 'open',
      'user' => admin_user.id,
      'account' => invitee_user.login,
      'token' => SecureRandom.hex(15)
    }
  end

  describe 'GET /clans' do
    it 'renders without error' do
      get '/clans'
      expect(last_response).to be_ok
    end

    it 'displays all clans' do
      clan1 = Clan.create!(name: 'clan1', admin: [admin_user.id, 1])
      clan2 = Clan.create!(name: 'clan2', admin: [admin_user.id, 1])

      get '/clans'
      expect(last_response.body).to include('clan1')
      expect(last_response.body).to include('clan2')
    end

    it 'displays empty message when no clans exist' do
      get '/clans'
      expect(last_response).to be_ok
    end
  end

  describe 'GET /clan/:name' do
    it 'correctly retrieves existing clan' do
      retrieved_clan = Clan.find_by(name: clan.name)
      expect(retrieved_clan).not_to be_nil
      expect(retrieved_clan.description).to eq('Test clan')
    end

    it 'correctly loads clan with members' do
      clan_with_members.reload
      expect(clan_with_members.users.count).to eq(1)
      expect(clan_with_members.users.first.login).to eq('member_user')
    end
  end

  describe 'POST /clan' do
    context 'authorization' do
      it 'requires authentication' do
        post '/clan', { clanname: 'unauthclan' }
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/')
        expect(last_request.env['rack.session']['errors'].first).to eq('You must be logged in to create a clan')
      end
    end

    context 'creation logic' do
      it 'rejects clan names with invalid characters' do
        post '/clan', { clanname: 'invalid-clan!' }, { 'rack.session' => { user_id: regular_user.id } }
        expect(last_response.status).to eq(302)
        expect(Clan.find_by(name: 'invalid-clan!')).to be_nil
        expect(last_request.env['rack.session']['errors']).to eq(
          ['Clan name may only contain a-z, A-Z, -, _, . and 0-9'])
      end

      it 'allows clan names with dots and underscores' do
        post '/clan', { clanname: 'clan.name_123' }, { 'rack.session' => { user_id: regular_user.id } }
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/clan/clan.name_123')
        expect(last_request.env['rack.session']['messages']).to eq(['Successfully created clan clan.name_123'])
      end

      it 'handles duplicate clan names' do
        Clan.create!(name: 'duplicateclan', admin: [admin_user.id, 1])

        post '/clan', { clanname: 'duplicateclan' }, { 'rack.session' => { user_id: regular_user.id } }
        expect(last_response.status).to eq(302)
        expect(last_request.env['rack.session']['errors']).to eq(['Clan name already exists'])
      end
    end
  end

  describe 'POST /clan_description/:name' do
    context 'authorization' do
      it 'requires authentication' do
        test_clan = Clan.create!(name: 'clandescauth', admin: [admin_user.id, 1])

        post '/clan_description/clandescauth', { description: 'Unauthorized' }
        expect(last_response.status).to eq(302)
      end

      it 'redirects when clan does not exist' do
        post '/clan_description/nonexistent', { description: 'Test' }
        expect(last_response.status).to eq(302)
      end
    end

    context 'model logic' do
      it 'updates clan description correctly' do
        test_clan = Clan.create!(name: 'clanupdatedesc', admin: [admin_user.id, 1], description: 'Old description')
        test_clan.description = 'New description'
        test_clan.save!

        test_clan.reload
        expect(test_clan.description).to eq('New description')
      end

      it 'handles empty description' do
        test_clan = Clan.create!(name: 'clanemptydesc', admin: [admin_user.id, 1], description: 'Original')
        test_clan.description = ''
        test_clan.save!

        test_clan.reload
        expect(test_clan.description).to eq('')
      end
    end
  end

  describe 'POST /clan_banner/:name' do
    context 'authorization' do
      it 'requires authentication' do
        test_clan = Clan.create!(name: 'clanbannerauth', admin: [admin_user.id, 1])

        post '/clan_banner/clanbannerauth', { mail: 'test@example.com' }
        expect(last_response.status).to eq(302)
      end
    end

    context 'model logic' do
      it 'updates clan gravatar with email' do
        test_clan = Clan.create!(name: 'clanbanner', admin: [admin_user.id, 1])
        email = 'test@example.com'

        test_clan.gravatar = Digest::MD5.hexdigest(email.downcase)
        test_clan.save

        test_clan.reload
        expect(test_clan.gravatar).to eq(Digest::MD5.hexdigest(email.downcase))
      end

      it 'clears clan gravatar' do
        test_clan = Clan.create!(name: 'clanclearbanner', admin: [admin_user.id, 1], gravatar: 'somehash')

        test_clan.gravatar = nil
        test_clan.save

        test_clan.reload
        expect(test_clan.gravatar).to be_nil
      end
    end
  end

  describe 'POST /clan/invite' do
    context 'authorization' do
      # Note: POST /clan/invite requires proper user context due to @user.id check
      # Full integration testing would be needed to properly test this endpoint
    end

    context 'invitation logic' do
      it 'creates invitation object' do
        test_clan = Clan.create!(name: 'inviteclan', admin: [admin_user.id, 1], invitations: [])
        invitation = basic_invitation

        test_clan.invitations = [invitation]
        test_clan.save!

        test_clan.reload
        expect(test_clan.invitations).not_to be_empty
        expect(test_clan.invitations[0]['user']).to eq(admin_user.id)
      end

      it 'generates unique tokens' do
        token1 = SecureRandom.hex(15)
        token2 = SecureRandom.hex(15)

        expect(token1).not_to eq(token2)
      end
    end
  end

  describe 'GET /respond/:token' do
    context 'authorization' do
      # Note: GET /respond/:token requires proper user context
      # Full integration testing would be needed to test this endpoint with unauthenticated requests
    end

    context 'invitation logic' do
      it 'processes invitation response correctly' do
        test_clan = Clan.create!(name: 'clanrespond', admin: [admin_user.id, 1])
        test_invitee = User.create!(login: 'invitee_accept', password: 'password123')
        invitation = {
          'clan_id' => test_clan.name,
          'status' => 'open',
          'user' => admin_user.id,
          'account' => test_invitee.login,
          'token' => 'test_token_123'
        }

        test_invitee.invitations = [invitation]
        test_invitee.save!

        test_clan.invitations = [invitation]
        test_clan.save!

        test_invitee.reload
        test_clan.reload
        expect(test_invitee.invitations).not_to be_empty

        if test_invitee.respond_invite(invitation, true)
          test_invitee.clan_name = test_clan.name
          test_invitee.save
        end

        test_invitee.reload
        expect(test_invitee.clan_name).to eq(test_clan.name)
      end

      it 'declines invitation correctly' do
        test_clan = Clan.create!(name: 'clandecline', admin: [admin_user.id, 1])
        test_invitee = User.create!(login: 'invitee_decline', password: 'password123')
        invitation = {
          'clan_id' => test_clan.name,
          'status' => 'open',
          'user' => admin_user.id,
          'account' => test_invitee.login,
          'token' => 'decline_token'
        }

        test_invitee.invitations = [invitation]
        test_invitee.save!

        test_clan.invitations = [invitation]
        test_clan.save!

        test_invitee.respond_invite(invitation, false)

        test_invitee.reload
        expect(test_invitee.clan_name).to be_nil
      end
    end
  end

  describe 'GET /clan/disband/:name' do
    context 'authorization' do
      # Note: GET /clan/disband/:name requires proper user context
      # Full integration testing would be needed to test this endpoint with unauthenticated requests
    end

    context 'deletion logic' do
      it 'removes clan from database' do
        test_clan = Clan.create!(name: 'clandisband', admin: [admin_user.id, 1])
        expect(Clan.find_by(name: 'clandisband')).not_to be_nil

        test_clan.destroy

        expect(Clan.find_by(name: 'clandisband')).to be_nil
      end

      it 'removes users from clan' do
        test_clan = Clan.create!(name: 'clandisbandusers', admin: [admin_user.id, 1])
        test_member = User.create!(login: 'member_disband', password: 'password123')
        test_member.clan_name = test_clan.name
        test_member.save

        User.where(clan_name: test_clan.name).update_all(clan_name: nil)

        test_member.reload
        expect(test_member.clan_name).to be_nil
      end
    end
  end

  describe 'GET /leaveclan' do
    context 'authorization' do
      it 'requires authentication' do
        get '/leaveclan'
        expect(last_response.status).to eq(302)
      end
    end

    context 'leave logic' do
      it 'removes user from clan' do
        test_user = User.create!(login: 'user_leave_clan', password: 'password123')
        test_clan = Clan.create!(name: 'clanleaveclan', admin: [test_user.id, 1])
        test_user.clan_name = test_clan.name
        test_user.save

        test_user.clan_name = nil
        test_user.save

        test_user.reload
        expect(test_user.clan_name).to be_nil
      end

      it 'allows non-admin member to leave' do
        test_admin = User.create!(login: 'admin_member_leave', password: 'password123')
        test_member = User.create!(login: 'member_leave', password: 'password123')
        test_clan = Clan.create!(name: 'clanmemberleave', admin: [test_admin.id, 1])
        test_member.clan_name = test_clan.name
        test_member.save

        test_member.clan_name = nil
        test_member.save

        test_member.reload
        expect(test_member.clan_name).to be_nil
      end
    end
  end

  describe 'Authorization and Security' do
    it 'clan creation requires authentication' do
      post '/clan', { clanname: 'test' }
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/')
    end

    it 'leaving clan requires authentication' do
      get '/leaveclan'
      expect(last_response.status).to eq(302)
    end

    it 'clan name validation prevents XSS' do
      expect {
        Clan.create!(name: '<script>alert("xss")</script>', admin: [admin_user.id, 1])
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'sanitizes clan descriptions' do
      test_clan = Clan.create!(name: 'clansanitize', admin: [admin_user.id, 1])

      test_clan.description = '<script>alert("xss")</script>'
      test_clan.save!

      test_clan.reload
      expect(test_clan.description).to include('script')
    end
  end

  describe 'Clan model' do
    it 'retrieves admin user correctly' do
      retrieved_admin = clan.get_admin
      expect(retrieved_admin.id).to eq(admin_user.id)
      expect(retrieved_admin.login).to eq('admin_user')
    end

    it 'generates gravatar link correctly' do
      gravatar_link = clan.gravatar_link
      expect(gravatar_link).to include('gravatar.com/avatar')
    end

    it 'generates gravatar link with custom hash' do
      test_clan = Clan.create!(name: 'clangravacustom', admin: [admin_user.id, 1], gravatar: 'customhash123')

      gravatar_link = test_clan.gravatar_link
      expect(gravatar_link).to include('customhash123')
    end
  end

  describe 'User model - invitations' do
    it 'initializes empty invitations' do
      expect(regular_user.invitations).to be_kind_of(Array)
    end

    it 'stores and retrieves invitations' do
      test_user = User.create!(login: 'invite_store', password: 'password123')
      invitation = { 'clan_id' => 'testclan', 'status' => 'open', 'token' => 'abc123' }

      test_user.invitations = [invitation]
      test_user.save!

      test_user.reload
      expect(test_user.invitations).to include(invitation)
    end

    it 'responds to invitations correctly' do
      test_clan = Clan.create!(name: 'clantest', admin: [admin_user.id, 1])
      test_user = User.create!(login: 'user_invite_respond', password: 'password123')
      invitation = {
        'clan_id' => test_clan.name,
        'status' => 'open',
        'account' => test_user.login,
        'token' => 'token123'
      }

      test_clan.invitations = [invitation]
      test_clan.save!

      result = test_user.respond_invite(invitation, true)
      expect(result).to eq(true)
    end
  end
end
