class RecommendedItem < ApplicationRecord
  belongs_to :team, optional: true
  belongs_to :company, optional: true
  belongs_to :category, optional: true

  validates :name, presence: true
end
