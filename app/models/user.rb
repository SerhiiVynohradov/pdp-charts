class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :company, optional: true
  belongs_to :team, optional: true

  has_many :items, dependent: :destroy
  has_many :item_progress_columns, dependent: :destroy
  has_many :progress_updates, through: :item_progress_columns

  enum role: {
    user: 0,
    manager: 1,
    company_owner: 2,
    superadmin: 3
  }

  def managed_teams
    Team.where(id: team_id)
  end

  def managed_team_ids
    managed_teams.pluck(:id)
  end

  def subordinates_ids
    team.users.pluck(:id)
  end

  def owned_teams
    Team.where(company_id: company_id)
  end

  def paused?
    false
  end
end
