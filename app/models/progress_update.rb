class ProgressUpdate < ApplicationRecord
  belongs_to :item
  belongs_to :item_progress_column

  validates :percent, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
