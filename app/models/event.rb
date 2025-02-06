class Event < ApplicationRecord
  belongs_to :eventable, polymorphic: true

  validates :name, presence: true
  validates :date, presence: true
end
