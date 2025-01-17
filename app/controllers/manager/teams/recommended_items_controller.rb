module Manager
  module Teams
    class RecommendedItemsController < ApplicationController
      before_action :set_context!

      include RecommendedItemsManagement

      private
      def set_context!
        redirect_to root_path unless user_signed_in? && current_user.manager?

        @team = current_user.managed_teams.find(params[:team_id])

        redirect_to root_path unless (can? :manage, @team)
      end
    end
  end
end
