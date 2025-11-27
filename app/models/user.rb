class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :lockable, :timeoutable, :confirmable

  enum :status, %i[inactive active banned deleted suspended], default: :inactive

  def currently_active?
    active?
  end

  def currently_banned?
    banned?
  end

  def currently_deleted?
    deleted?
  end

  def currently_suspended?
    suspended?
  end

  def currently_inactive?
    inactive?
  end

  def soft_delete
    update(status: :deleted, deleted_at: Time.current)
  end

  # Override destroy to soft delete by default
  def destroy
    soft_delete
  end

  # Override delete to soft delete by default
  def delete
    soft_delete
  end

  # Permanent deletion methods
  def hard_delete!
    # Directly delete from database without callbacks
    self.class.delete(id)
  end

  def hard_destroy!
    # Call original ActiveRecord destroy
    # Save the result before calling super to avoid recursion
    run_callbacks(:destroy) do
      self.class.delete(id)
    end
  end

  def ban_user
    update(status: :banned, banned_at: Time.current)
  end

  def suspend_user
    update(status: :suspended, suspended_at: Time.current)
  end

  def activate_user
    update(status: :active)
  end

  def reactivate
    update(
      status: :active,
      deleted_at: nil,
      banned_at: nil,
      suspended_at: nil
    )
  end
end