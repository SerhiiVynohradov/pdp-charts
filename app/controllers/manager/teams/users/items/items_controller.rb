module Manager
  module Teams
    module Users
      module Items
        class ItemsController < ApplicationController
          before_action :authenticate_user!

          before_action :set_team

          include ItemManagement

          private
          def set_team
            @team = current_user.managed_teams.find(params[:team_id])
          end
        end
      end
    end
  end
end
