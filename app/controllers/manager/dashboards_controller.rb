module Manager
  class DashboardsController < Manager::BaseController
    def index
      redirect_to manager_team_path(current_user.team)
    end
  end
end
