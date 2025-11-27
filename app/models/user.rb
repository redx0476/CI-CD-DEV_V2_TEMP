class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :lockable, :timeoutable, :confirmable

  enum status: { inactive: 0, active: 1, banned: 2, deleted: 3, suspended: 4 }

  def currently_active?
    status == :active
  end

  def currently_banned?
    status == :banned
  end

  def currently_deleted?
    status == :deleted
  end

  def currently_suspended?
    status == :suspended
  end

  def currently_inactive?
    status == :inactive
  end
end
