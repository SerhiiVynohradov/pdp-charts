class Company < ApplicationRecord
  default_scope { order(:name) }

  has_many :teams, dependent: :destroy
  has_many :users # direct employees without teams
  has_one :owner, class_name: 'User'
  has_many :invoices, as: :invoiceable, dependent: :nullify

  validates :name, presence: true

  def active?
    status
  end
end
