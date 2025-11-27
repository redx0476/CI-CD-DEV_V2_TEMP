# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('invalid_email').for(:email) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }
  end

  describe 'devise modules' do
    it 'has database_authenticatable module' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'has registerable module' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'has recoverable module' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'has rememberable module' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'has validatable module' do
      expect(User.devise_modules).to include(:validatable)
    end

    it 'has trackable module' do
      expect(User.devise_modules).to include(:trackable)
    end

    it 'has lockable module' do
      expect(User.devise_modules).to include(:lockable)
    end

    it 'has timeoutable module' do
      expect(User.devise_modules).to include(:timeoutable)
    end

    it 'has confirmable module' do
      expect(User.devise_modules).to include(:confirmable)
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(inactive: 0, active: 1, banned: 2, deleted: 3, suspended: 4) }

    it 'has inactive as default status' do
      user = User.new
      expect(user.status).to eq('inactive')
    end
  end

  describe 'status scopes' do
    let!(:inactive_user) { create(:user, :inactive) }
    let!(:active_user) { create(:user) }
    let!(:banned_user) { create(:user, :banned) }
    let!(:deleted_user) { create(:user, :deleted) }
    let!(:suspended_user) { create(:user, :suspended) }

    it 'returns inactive users' do
      expect(User.inactive).to include(inactive_user)
      expect(User.inactive).not_to include(active_user)
    end

    it 'returns active users' do
      expect(User.active).to include(active_user)
      expect(User.active).not_to include(inactive_user)
    end

    it 'returns banned users' do
      expect(User.banned).to include(banned_user)
      expect(User.banned).not_to include(active_user)
    end

    it 'returns deleted users' do
      expect(User.deleted).to include(deleted_user)
      expect(User.deleted).not_to include(active_user)
    end

    it 'returns suspended users' do
      expect(User.suspended).to include(suspended_user)
      expect(User.suspended).not_to include(active_user)
    end
  end

  describe '#currently_active?' do
    it 'returns true when user status is active' do
      user = build(:user, status: :active)
      expect(user.currently_active?).to be true
    end

    it 'returns false when user status is not active' do
      user = build(:user, :inactive)
      expect(user.currently_active?).to be false
    end
  end

  describe '#currently_banned?' do
    it 'returns true when user status is banned' do
      user = build(:user, :banned)
      expect(user.currently_banned?).to be true
    end

    it 'returns false when user status is not banned' do
      user = build(:user)
      expect(user.currently_banned?).to be false
    end
  end

  describe '#currently_deleted?' do
    it 'returns true when user status is deleted' do
      user = build(:user, :deleted)
      expect(user.currently_deleted?).to be true
    end

    it 'returns false when user status is not deleted' do
      user = build(:user)
      expect(user.currently_deleted?).to be false
    end
  end

  describe '#currently_suspended?' do
    it 'returns true when user status is suspended' do
      user = build(:user, :suspended)
      expect(user.currently_suspended?).to be true
    end

    it 'returns false when user status is not suspended' do
      user = build(:user)
      expect(user.currently_suspended?).to be false
    end
  end

  describe '#currently_inactive?' do
    it 'returns true when user status is inactive' do
      user = build(:user, :inactive)
      expect(user.currently_inactive?).to be true
    end

    it 'returns false when user status is not inactive' do
      user = build(:user)
      expect(user.currently_inactive?).to be false
    end
  end

  describe 'status transitions' do
    let(:user) { create(:user, :inactive) }

    it 'can transition from inactive to active' do
      user.active!
      expect(user.status).to eq('active')
      expect(user.currently_active?).to be true
    end

    it 'can transition from active to banned' do
      user.active!
      user.banned!
      expect(user.status).to eq('banned')
      expect(user.currently_banned?).to be true
    end

    it 'can transition from active to suspended' do
      user.active!
      user.suspended!
      expect(user.status).to eq('suspended')
      expect(user.currently_suspended?).to be true
    end

    it 'can transition from active to deleted' do
      user.active!
      user.deleted!
      expect(user.status).to eq('deleted')
      expect(user.currently_deleted?).to be true
    end
  end

  describe 'factory traits' do
    it 'creates an active user by default' do
      user = create(:user)
      expect(user.status).to eq('active')
      expect(user.currently_active).to be true
    end

    it 'creates an inactive user with inactive trait' do
      user = create(:user, :inactive)
      expect(user.status).to eq('inactive')
      expect(user.currently_active).to be false
    end

    it 'creates a banned user with banned trait' do
      user = create(:user, :banned)
      expect(user.status).to eq('banned')
      expect(user.currently_active).to be false
    end

    it 'creates a deleted user with deleted trait' do
      user = create(:user, :deleted)
      expect(user.status).to eq('deleted')
      expect(user.currently_active).to be false
    end

    it 'creates a suspended user with suspended trait' do
      user = create(:user, :suspended)
      expect(user.status).to eq('suspended')
      expect(user.currently_active).to be false
    end
  end

  describe 'trackable attributes' do
    let(:user) { create(:user) }

    it 'tracks sign in count' do
      expect(user).to respond_to(:sign_in_count)
    end

    it 'tracks current sign in at' do
      expect(user).to respond_to(:current_sign_in_at)
    end

    it 'tracks last sign in at' do
      expect(user).to respond_to(:last_sign_in_at)
    end

    it 'tracks current sign in ip' do
      expect(user).to respond_to(:current_sign_in_ip)
    end

    it 'tracks last sign in ip' do
      expect(user).to respond_to(:last_sign_in_ip)
    end
  end

  describe 'lockable attributes' do
    let(:user) { create(:user) }

    it 'tracks failed attempts' do
      expect(user).to respond_to(:failed_attempts)
    end

    it 'tracks unlock token' do
      expect(user).to respond_to(:unlock_token)
    end

    it 'tracks locked at' do
      expect(user).to respond_to(:locked_at)
    end
  end

  describe 'confirmable attributes' do
    let(:user) { create(:user) }

    it 'tracks confirmation token' do
      expect(user).to respond_to(:confirmation_token)
    end

    it 'tracks confirmed at' do
      expect(user).to respond_to(:confirmed_at)
    end

    it 'tracks confirmation sent at' do
      expect(user).to respond_to(:confirmation_sent_at)
    end

    it 'tracks unconfirmed email' do
      expect(user).to respond_to(:unconfirmed_email)
    end
  end

  describe 'attributes' do
    let(:user) { create(:user) }

    it 'has user_name attribute' do
      expect(user).to respond_to(:user_name)
    end

    it 'has currently_active attribute' do
      expect(user).to respond_to(:currently_active)
    end

    it 'generates unique email' do
      user1 = create(:user)
      user2 = create(:user)
      expect(user1.email).not_to eq(user2.email)
    end

    it 'generates user_name' do
      expect(user.user_name).to be_present
    end
  end

  # ==================== NEW TESTS BELOW ====================

  describe '#soft_delete' do
    let(:user) { create(:user, status: :active) }

    it 'changes status to deleted' do
      expect { user.soft_delete }.to change { user.status }.from('active').to('deleted')
    end

    it 'sets deleted_at timestamp' do
      expect { user.soft_delete }.to change { user.deleted_at }.from(nil)
      expect(user.deleted_at).to be_present
    end

    it 'keeps user in database' do
      user_id = user.id
      user.soft_delete
      expect(User.find_by(id: user_id)).to be_present
    end

    it 'returns true on success' do
      expect(user.soft_delete).to be_truthy
    end
  end

  describe '#destroy' do
    context 'with default behavior (soft delete)' do
      let(:user) { create(:user, status: :active) }

      it 'soft deletes the user' do
        user.destroy
        expect(user.status).to eq('deleted')
      end

      it 'sets deleted_at timestamp' do
        user.destroy
        expect(user.deleted_at).to be_present
      end

      it 'does not remove user from database' do
        user_id = user.id
        user.destroy
        expect(User.find_by(id: user_id)).to be_present
      end
    end

    context 'with hard_delete = true' do
      let(:user) { create(:user) }

      it 'permanently removes user from database' do
        user_id = user.id
        user.destroy(true)
        expect(User.find_by(id: user_id)).to be_nil
      end
    end
  end


  describe '#destroy' do
    context 'with default behavior (soft delete)' do
      let(:user) { create(:user, status: :active) }

      it 'soft deletes the user' do
        user.destroy
        expect(user.status).to eq('deleted')
      end

      it 'sets deleted_at timestamp' do
        user.destroy
        expect(user.deleted_at).to be_present
      end

      it 'does not remove user from database' do
        user_id = user.id
        user.destroy
        expect(User.find_by(id: user_id)).to be_present
      end
    end
  end

  describe '#delete' do
    context 'with default behavior (soft delete)' do
      let(:user) { create(:user, status: :active) }

      it 'soft deletes the user' do
        user.delete
        expect(user.reload.status).to eq('deleted')
      end

      it 'does not remove user from database' do
        user_id = user.id
        user.delete
        expect(User.find_by(id: user_id)).to be_present
      end
    end
  end

  describe '#hard_delete!' do
    let(:user) { create(:user) }

    it 'permanently removes user from database' do
      user_id = user.id
      user.hard_delete!
      expect(User.find_by(id: user_id)).to be_nil
    end

    it 'does not just soft delete' do
      user_id = user.id
      user.hard_delete!
      expect(User.find_by(id: user_id)).to be_nil
    end
  end

  describe '#hard_destroy!' do
    let(:user) { create(:user) }

    it 'permanently removes user from database' do
      user_id = user.id
      user.hard_destroy!
      expect(User.find_by(id: user_id)).to be_nil
    end
  end

  describe '#ban_user' do
    let(:user) { create(:user, status: :active) }

    it 'changes status to banned' do
      expect { user.ban_user }.to change { user.status }.from('active').to('banned')
    end

    it 'sets banned_at timestamp' do
      expect { user.ban_user }.to change { user.banned_at }.from(nil)
      expect(user.banned_at).to be_present
    end

    it 'returns true on success' do
      expect(user.ban_user).to be_truthy
    end

    it 'makes user currently_banned?' do
      user.ban_user
      expect(user.currently_banned?).to be true
    end
  end

  describe '#suspend_user' do
    let(:user) { create(:user, status: :active) }

    it 'changes status to suspended' do
      expect { user.suspend_user }.to change { user.status }.from('active').to('suspended')
    end

    it 'sets suspended_at timestamp' do
      expect { user.suspend_user }.to change { user.suspended_at }.from(nil)
      expect(user.suspended_at).to be_present
    end

    it 'returns true on success' do
      expect(user.suspend_user).to be_truthy
    end

    it 'makes user currently_suspended?' do
      user.suspend_user
      expect(user.currently_suspended?).to be true
    end
  end

  describe '#activate_user' do
    let(:user) { create(:user, :inactive) }

    it 'changes status to active' do
      expect { user.activate_user }.to change { user.status }.from('inactive').to('active')
    end

    it 'returns true on success' do
      expect(user.activate_user).to be_truthy
    end

    it 'makes user currently_active?' do
      user.activate_user
      expect(user.currently_active?).to be true
    end

    context 'when user is banned' do
      let(:banned_user) { create(:user, :banned) }

      it 'can activate a banned user' do
        banned_user.activate_user
        expect(banned_user.currently_active?).to be true
      end
    end

    context 'when user is suspended' do
      let(:suspended_user) { create(:user, :suspended) }

      it 'can activate a suspended user' do
        suspended_user.activate_user
        expect(suspended_user.currently_active?).to be true
      end
    end
  end

  describe '#reactivate' do
    let(:user) do
      create(:user,
        status: :deleted,
        deleted_at: 1.day.ago,
        banned_at: 2.days.ago,
        suspended_at: 3.days.ago
      )
    end

    it 'changes status to active' do
      expect { user.reactivate }.to change { user.status }.to('active')
    end

    it 'clears deleted_at timestamp' do
      expect { user.reactivate }.to change { user.deleted_at }.to(nil)
    end

    it 'clears banned_at timestamp' do
      expect { user.reactivate }.to change { user.banned_at }.to(nil)
    end

    it 'clears suspended_at timestamp' do
      expect { user.reactivate }.to change { user.suspended_at }.to(nil)
    end

    it 'returns true on success' do
      expect(user.reactivate).to be_truthy
    end

    it 'makes user currently_active?' do
      user.reactivate
      expect(user.currently_active?).to be true
    end

    it 'clears all status timestamps in one action' do
      user.reactivate
      expect(user.deleted_at).to be_nil
      expect(user.banned_at).to be_nil
      expect(user.suspended_at).to be_nil
    end
  end

  describe 'timestamp attributes' do
    let(:user) { create(:user) }

    it 'has deleted_at attribute' do
      expect(user).to respond_to(:deleted_at)
    end

    it 'has banned_at attribute' do
      expect(user).to respond_to(:banned_at)
    end

    it 'has suspended_at attribute' do
      expect(user).to respond_to(:suspended_at)
    end

    it 'deleted_at is nil by default' do
      expect(user.deleted_at).to be_nil
    end

    it 'banned_at is nil by default' do
      expect(user.banned_at).to be_nil
    end

    it 'suspended_at is nil by default' do
      expect(user.suspended_at).to be_nil
    end
  end

  describe 'status change workflow' do
    let(:user) { create(:user, status: :active) }

    it 'allows ban -> reactivate workflow' do
      user.ban_user
      expect(user.currently_banned?).to be true

      user.reactivate
      expect(user.currently_active?).to be true
      expect(user.banned_at).to be_nil
    end

    it 'allows suspend -> reactivate workflow' do
      user.suspend_user
      expect(user.currently_suspended?).to be true

      user.reactivate
      expect(user.currently_active?).to be true
      expect(user.suspended_at).to be_nil
    end

    it 'allows soft_delete -> reactivate workflow' do
      user.soft_delete
      expect(user.currently_deleted?).to be true

      user.reactivate
      expect(user.currently_active?).to be true
      expect(user.deleted_at).to be_nil
    end

    it 'allows multiple status changes' do
      user.suspend_user
      expect(user.currently_suspended?).to be true

      user.ban_user
      expect(user.currently_banned?).to be true

      user.soft_delete
      expect(user.currently_deleted?).to be true

      user.reactivate
      expect(user.currently_active?).to be true
      expect(user.deleted_at).to be_nil
      expect(user.banned_at).to be_nil
      expect(user.suspended_at).to be_nil
    end
  end
end
