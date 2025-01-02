class Item < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  default_scope { order(position: :asc, created_at: :asc) }

  def status_label
    'Status Label'
  end
end
