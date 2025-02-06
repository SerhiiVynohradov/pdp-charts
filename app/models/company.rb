class Company < ApplicationRecord
  default_scope { order(:name) }

  has_many :teams, dependent: :destroy
  has_many :users # direct employees without teams
  has_one :owner, class_name: 'User'
  has_many :invoices, as: :invoiceable, dependent: :nullify

  has_many :events, as: :eventable, dependent: :destroy

  validates :name, presence: true

  def active?
    status
  end
end
