module My
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_context!

    private

    def set_context!
      @sidebar_context = if current_user.superadmin?
                           :superadmin
                         elsif current_user.company_owner?
                           :company_owner
                         elsif current_user.manager?
                           :manager
                         else
                           :user
                         end

      @user = current_user

      redirect_to root_path unless can? :read, @user

      if current_user.superadmin?
        @sidebar_companies = Company.all

        @search_companies = Company.all
        @search_teams = Team.all
        @search_users = User.all
      elsif current_user.company_owner?
        @sidebar_companies = [current_user.company]

        @search_companies = [current_user.company]
        @search_teams = current_user.company.teams
        @search_users = current_user.company.teams.map(&:users).flatten
      elsif current_user.manager?
        []
      else
        []
      end
    end

    def read_only_mode
      true
    end
  end
end
