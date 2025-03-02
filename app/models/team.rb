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

  def items_count
    users.map { |u| u.items.count }.sum
  end

  def items_finished_count
    users.map { |u| u.items.select { |i| i.progress == 100 }.count }.sum
  end
end
