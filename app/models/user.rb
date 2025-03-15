class User < ApplicationRecord
  include PdpChartsHelper
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  default_scope { order(:name) }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :linkedin, :facebook]

  belongs_to :company, optional: true
  belongs_to :team, optional: true

  has_many :items, dependent: :destroy
  has_many :item_progress_columns, dependent: :destroy
  has_many :progress_updates, through: :item_progress_columns
  has_many :invoices, as: :invoiceable, dependent: :nullify

  has_many :events, as: :eventable, dependent: :destroy

  has_many :user_accounts, dependent: :destroy

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
      if manager.nil?
        return "No manager found for team id: #{self.team.id}"
      else
        return "#{manager.name} (user/manager id: #{manager.id})"
      end
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
    team.users.pluck(:id) - [id]
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

  def items_count
    items.count
  end

  def items_finished_count
    items.select { |i| i.progress == 100 }.count
  end

  def performance
    # 1) Берём «готовый» метод, который вы уже вызываете в контроллерах
    #    чтобы построить график по items этого пользователя.
    stats = build_pdp_charts_data(self.items, label: self.name)
    # => вернёт { label:..., items_data: [...], wa_data: [...], effort_data: [...] }

    # 2) Берём effort_data – это массив точек [{ x: ..., y: ... }, ...]
    effort_points = stats[:effort_data]

    # 3) Предполагаем, что последний элемент массива соответствует текущему кварталу
    #    (т.к. quarters сортируются от первого к текущему).
    last_point = effort_points.last
    current_value = last_point ? last_point[:y] : 0

    # 4) Сравниваем с порогами 200 и 1000
    if current_value < 200
      "low"
    elsif current_value > 1000
      "high"
    else
      "medium"
    end
  end
end
