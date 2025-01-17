class Invoice < ApplicationRecord
  belongs_to :invoiceable, polymorphic: true

  validates :number, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
end
