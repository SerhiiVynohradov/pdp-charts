module My
  module Teams
    class TeamsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_team, only: :show

      def show
        redirect_to my_team_users_path(@team)
      end

      private

      def set_team
        @team = current_user.team
      end

      def read_only_mode
        true
      end
    end
  end
end
