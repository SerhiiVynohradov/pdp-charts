module Superadmin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_context!

    private
    def set_context!
      redirect_to root_path unless current_user.superadmin?
      @superadmin = true
      @sidebar_context = :superadmin

      @sidebar_companies = Company.all

      @search_companies = Company.all
      @search_teams = Team.all
      @search_users = User.all
    end
  end
end
