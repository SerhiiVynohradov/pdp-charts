class ItemProgressColumn < ApplicationRecord
  attr_accessor :full_year

  belongs_to :user
  has_many :progress_updates, dependent: :destroy

  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id, message: "already exists for this user" }
end
