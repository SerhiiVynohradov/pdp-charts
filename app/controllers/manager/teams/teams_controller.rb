module Manager
  module Teams
    class TeamsController < ApplicationController
      include TeamManagement

      before_action :require_manager!
      before_action :set_team, only: [:show, :update, :destroy]
      before_action :authorize_manage_team!, only: [:show, :update, :destroy]

      def show
        redirect_to manager_team_users_path(params[:id])
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
    end
  end
end
