module Manager
  module Teams
    module Users
      class RecommendedItemsController < ApplicationController
        include RecommendedItemsFetching
        before_action :set_context

        private

        def set_context
          redirect_to root_path unless user_signed_in? && current_user.manager?

          @team = current_user.managed_teams.find(params[:team_id])

          redirect_to root_path unless (can? :manage, @team)

          @user = @team.users.find(params[:user_id])
        end
      end
    end
  end
end
