class Company < ApplicationRecord
  default_scope { order(:name) }

  has_many :teams, dependent: :destroy
  has_many :users, dependent: :nullify
  has_one :owner, class_name: 'User', foreign_key: 'company_id', dependent: :nullify
  has_many :invoices, as: :invoiceable, dependent: :nullify

  has_many :events, as: :eventable, dependent: :destroy

  validates :name, presence: true

  def active?
    status
  end

  # todo: n+1
  def items_count
    teams.map { |t| t.items_count }.sum
  end

  # todo: n+1
  def items_finished_count
    teams.map { |t| t.items_finished_count }.sum
  end
end
