class Company < ApplicationRecord
  has_many :teams
  has_many :users # direct employees without teams

  validates :name, presence: true
end
