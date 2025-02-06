module Manager
  module Teams
    module Users
      module Events
        class EventsController < ApplicationController
          before_action :set_context

          include EventManagement

          private
          def set_context
            redirect_to root_path unless current_user&.manager?
            @team = Team.find(params[:team_id])
            redirect_to root_path unless can? :read, @team
            @user = @team.users.find(params[:user_id])
            redirect_to root_path unless can? :read, @user
          end

          def object
            @user
          end
        end
      end
    end
  end
end
