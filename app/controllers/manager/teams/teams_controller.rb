module Manager
  module Teams
    class TeamsController < Manager::BaseController
      include TeamManagement

      before_action :set_team, only: [:show, :edit, :update, :destroy]
      before_action :authorize_manage_team!, only: [:show, :update, :destroy]

      def show
        redirect_to manager_team_users_path(params[:id])
      end

      def edit

      end

      def update
        if @team.update(team_params)
          redirect_to edit_manager_team_path(current_user.team), notice: I18n.t('messages.settings.saved_successfully')
        else
          render :edit
        end
      end

      private
      def set_team
        @team = current_user.managed_teams.find(params[:id])
      end

      def authorize_manage_team!
        redirect_to root_path unless @team.present? && (can? :manage, @team)
      end

      def team_params
        params.require(:team).permit(:name, :charts_visible, :status, :effort_line, :wa_line, :items_line)
      end
    end
  end
end
