module Manager
  class DashboardsController < ApplicationController
    before_action :require_manager!

    def index
      redirect_to manager_team_path(current_user.team)
    end

    private
    def require_manager!
      unless current_user&.manager?
        redirect_to root_path, alert: "Not allowed"
      end
    end
  end
end
