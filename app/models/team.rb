class Team < ApplicationRecord
  default_scope { order(:name) }

  belongs_to :company, optional: true

  has_many :users, dependent: :destroy

  has_many :events, as: :eventable, dependent: :destroy

  validates :name, presence: true

  def active?
    status
  end

  def manager
    users.where(role: "manager").first
  end
end
