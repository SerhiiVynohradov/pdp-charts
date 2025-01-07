module Manager
  module Teams
    module Users
      class ItemProgressColumnsController < ApplicationController
        before_action :authenticate_user!
        before_action :set_team
        before_action :authorize_manage_team!

        include ItemProgressColumnManagement

        private
        def set_user
          @user = @team.users.find(params[:user_id])
        end

        def set_team
          @team = current_user.managed_teams.find(params[:team_id])
        end

        def authorize_manage_team!
          redirect_to root_path unless can?(:manage, @team)
        end
      end
    end
  end
end
