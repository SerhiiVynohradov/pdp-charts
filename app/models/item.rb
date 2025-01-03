class Item < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  default_scope { order(position: :asc, created_at: :asc) }

  def status_label
    'Status Label'
  end

  def progress_updates
    4.times.map do
      {
        date: random_date_2024,
        percent: rand(0..100)
      }
    end.sort_by { |point| point[:date] }
  end

  private

  def random_date_2024
    day_of_year = rand(1..365)
    Date.new(2024, 1, 1) + (day_of_year - 1)
  end
end
