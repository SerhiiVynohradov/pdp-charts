class Item < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  has_many :progress_updates, dependent: :destroy

  validates :name, presence: true
  validates :effort, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  default_scope { order(position: :asc, created_at: :asc) }

  def status_label
    'Status Label'
  end

  # todo: validate so that each next progress_update has a bigger progress than the previous one
  def quarter_progress(q_start, q_end)
    relevant_progress_updates = progress_updates.joins(:item_progress_column)
                                                .where(item_progress_columns: { date: q_start..q_end })

    relevant_progress_updates.maximum(:percent) || 0
  end

  def progress
    if progress_updates.loaded?
      progress_updates.map(&:percent).compact.max || 0
    else
      progress_updates.maximum(:percent) || 0
    end
  end
end
