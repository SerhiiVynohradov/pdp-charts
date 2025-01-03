module Manager
  module Teams
    class TeamsController < ApplicationController
      include PdpChartsHelper

      before_action :require_manager!
      # load_and_authorize_resource if using CanCan

      def show
        @team = current_user.managed_teams.find(params[:id])

        @chart_data = @team.users.map do |u|
          build_pdp_charts_data(u.items, label: u.name)
        end
        @chart_label = "PDP Chart for team #{@team.name}"
      end

      def charts
        @team = current_user.managed_teams.find(params[:id])
        # build multi-line chart for each user in the team
      end

      def settings
        @team = current_user.managed_teams.find(params[:id])
      end

      def recommended
        @team = current_user.managed_teams.find(params[:id])
        # recommended items CRUD
      end

      private
      def require_manager!
        redirect_to root_path unless user_signed_in? && current_user.manager?
      end
    end
  end
end
