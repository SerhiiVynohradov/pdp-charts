module Manager
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_manager_context!

    private
    def set_manager_context!
      redirect_to root_path unless current_user.manager?
      @sidebar_context = :manager

      @sidebar_companies = [current_user.team&.company].compact

      @search_companies = [current_user.team&.company].compact
      @search_teams = [current_user.team].compact
      @search_users = [current_user.team&.users].compact.flatten
    end
  end
end
