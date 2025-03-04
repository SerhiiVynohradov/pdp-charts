module Manager
  module Teams
    class BaseController < Manager::BaseController
      before_action :set_team_context!

      private
      def set_team_context!
        @team = current_user.managed_teams.find(params[:team_id])
        redirect_to root_path unless @team.present? && (can? :manage, @team)
      end
    end
  end
end
