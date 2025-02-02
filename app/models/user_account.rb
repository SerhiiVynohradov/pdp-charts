class UserAccount < ApplicationRecord
  belongs_to :user

  def expired?
    expired_at < Time.zone.now
  end
end
