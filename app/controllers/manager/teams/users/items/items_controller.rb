module Manager
  module Teams
    module Users
      module Items
        class ItemsController < ApplicationController
          before_action :authenticate_user!
          before_action :set_team
          before_action :authorize_manage_team!

          include ItemManagement
          include ItemProgressColumnManagement
          include ProgressUpdateManagement

          private

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
end
