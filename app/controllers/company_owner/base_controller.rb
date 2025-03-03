module CompanyOwner
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_context!

    private
    def set_context!
      redirect_to root_path unless current_user.company_owner?
      @sidebar_context = :company_owner

      @sidebar_companies = [current_user.company]

      @search_companies = [current_user.company]
      @search_teams = current_user.company.teams
      @search_users = current_user.company.teams.map(&:users).flatten
    end
  end
end
