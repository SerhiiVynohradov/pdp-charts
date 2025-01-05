module Manager
  module Teams
    module Users
      class UsersController < ApplicationController
        before_action :require_manager!

        include UserManagement

        def show
          redirect_to manager_team_user_items_path(@team, @user)
        end

        private

        def require_manager!
          redirect_to root_path unless user_signed_in? && current_user.manager?
        end

        def set_team
          @team = current_user.managed_teams.find(params[:team_id])
        end
      end
    end
  end
end
