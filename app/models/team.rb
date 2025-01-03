class Team < ApplicationRecord
  belongs_to :company, optional: true

  has_many :users

  validates :name, presence: true
end
