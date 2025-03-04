module My
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_my_context!

    private

    def set_my_context!
      @user = current_user

      redirect_to root_path unless can? :read, @user

      if current_user.superadmin?
        @sidebar_context = :superadmin
        @sidebar_companies = Company.all

        @search_companies = Company.all
        @search_teams = Team.all
        @search_users = User.all
      elsif current_user.company_owner?
        @sidebar_context = :company_owner
        @sidebar_companies = [current_user.company]

        @search_companies = [current_user.company]
        @search_teams = current_user.company.teams
        @search_users = current_user.company.teams.map(&:users).flatten
      elsif current_user.manager?
        @sidebar_context = :manager
        @sidebar_companies = [current_user.team&.company].compact

        @search_companies = [current_user.team&.company].compact
        @search_teams = [current_user.team].compact
        @search_users = [current_user.team&.users].compact.flatten
      else
        @sidebar_context = :user
        @sidebar_companies = [current_user.team&.company].compact

        @search_companies = [current_user.team&.company].compact
        @search_teams = [current_user.team].compact
        @search_users = [current_user.team&.users].compact.flatten
      end
    end

    # todo: fix with smth better
    def read_only_mode
      true
    end
  end
end
