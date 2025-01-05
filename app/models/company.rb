class Company < ApplicationRecord
  has_many :teams
  has_many :users # direct employees without teams
  has_one :owner, class_name: 'User'

  validates :name, presence: true
end
