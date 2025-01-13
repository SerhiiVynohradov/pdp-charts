module Manager
  module Teams
    class TeamsController < ApplicationController
      include TeamManagement

      before_action :require_manager!
      before_action :set_team, only: [:show, :edit, :update, :destroy]
      before_action :authorize_manage_team!, only: [:show, :update, :destroy]

      def show
        redirect_to manager_team_users_path(params[:id])
      end

      def edit

      end

      def update
        if @team.update(team_params)
          redirect_to edit_manager_team_path(current_user.team), notice: "Team settings updated."
        else
          render :edit
        end
      end

      private
      def require_manager!
        redirect_to root_path unless user_signed_in? && current_user.manager?
      end

      def set_team
        @team = Team.find(params[:id])
      end

      def authorize_manage_team!
        redirect_to root_path unless @team.present? && (can? :manage, @team)
      end

      def team_params
        params.require(:team).permit(:name, :charts_visible, :status)
      end
    end
  end
end
