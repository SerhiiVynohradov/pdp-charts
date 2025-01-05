class Company < ApplicationRecord
  has_many :teams, dependent: :destroy
  has_many :users # direct employees without teams
  has_one :owner, class_name: 'User'

  validates :name, presence: true

  def active?
    status
  end
end
