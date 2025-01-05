class Team < ApplicationRecord
  belongs_to :company, optional: true

  has_many :users, dependent: :destroy

  validates :name, presence: true

  def active?
    status
  end
end
