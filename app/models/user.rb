class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  default_scope { order(:name) }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :company, optional: true
  belongs_to :team, optional: true

  has_many :items, dependent: :destroy
  has_many :item_progress_columns, dependent: :destroy
  has_many :progress_updates, through: :item_progress_columns
  has_many :invoices, as: :invoiceable, dependent: :nullify

  enum role: {
    user: 0,
    manager: 1,
    company_owner: 2,
    superadmin: 3
  }

  def self.payers
    all.select { |user| user.payer == user }
  end

  def managed_teams
    Team.where(id: team_id)
  end

  def payer_info
    # Сценарий 1: у юзера нет команды => платит он сам
    return "#{self.name} (user id: #{self.id})" if self.team.nil?

    # Сценарий 2: у юзера есть команда, но нет компании => платит менеджер
    if self.team.company.nil?
      manager = self.team.manager
      return "#{manager.name} (user/manager id: #{manager.id})"
    end

    # Сценарий 3: у юзера есть компания => платит компания
    company = self.team.company
    "#{company.name} (company id: #{company.id})"
  end

  def payer
    # Сценарий 1: у юзера нет команды => платит он сам
    return self if self.team.nil?

    # Сценарий 2: у юзера есть команда, но нет компании => платит менеджер
    if self.team.company.nil?
      return self.team.manager
    end

    # Сценарий 3: у юзера есть компания => платит компания
    return self.team.company
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

  def create_quarters(year="2024")
    ["10 Jan #{year}", "10 Apr #{year}", "10 Jul #{year}", "10 Oct #{year}"].each do |date|
      item_progress_columns.create(date: date)
    end
  end

  def paused?
    false
  end
end
