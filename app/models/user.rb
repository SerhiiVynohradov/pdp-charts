class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :company, optional: true
  belongs_to :team, optional: true

  has_many :items

  enum role: {
    user: 0,
    manager: 1,
    company_owner: 2,
    superadmin: 3
  }

  def managed_teams
    Team.where(id: team_id)
  end

  def subordinates_ids
    if manager?
      team.users.where.not(id: id).pluck(:id)
    elsif company_owner?
      company.teams.joins(:users).where.not(users: { id: id }).pluck(:id)
    else
      []
    end
  end

  def paused?
    false
  end
end
