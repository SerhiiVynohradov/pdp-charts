class Item < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  default_scope { order(position: :asc, created_at: :asc) }

  def status_label
    'Status Label'
  end

  def progress_updates
    # DEMO: returns random data for the year 2024
    # In real life, you'd store them in a separate table and fetch from DB.
    [
      { date: Date.new(2024,2,10),  percent: 30 },
      { date: Date.new(2024,4,15),  percent: 50 },
      { date: Date.new(2024,8,1),   percent: 80 },
      { date: Date.new(2024,10,5),  percent: 100 }
    ]
  end

  def quarter_progress(q_start, q_end)
    # Finds any progress update that falls in [q_start..q_end].
    # If multiple, you might take the *latest* or *max*?
    # For demonstration, let's just pick the max percent in that window.
    relevant_updates = progress_updates.select do |upd|
      upd[:date].between?(q_start, q_end)
    end
    if relevant_updates.any?
      relevant_updates.map { |u| u[:percent] }.max
    else
      nil
    end
  end
end
