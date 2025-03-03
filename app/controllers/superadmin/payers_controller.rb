module Superadmin
  class PayersController < Superadmin::BaseController
    def index
      @self_employed = User.where(team_id: nil).to_a
      @managers = User.where(role: :manager).select { |user| user.team.company.nil? }.to_a

      @companies = Company.all

      @teams_with_companies = Team.where.not(company_id: nil).to_a
      @users_paid_by_companies = @teams_with_companies.map(&:users).flatten

      @users_paid_by_managers = User.where(team_id: @managers.map(&:team_id)).to_a
    end

    def show
      @payer = User.find(params[:id])
    end
  end
end
