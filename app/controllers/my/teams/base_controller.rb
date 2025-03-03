module My
  module Teams
    class BaseController < ApplicationController
      before_action :set_team_context!

      private

      def set_team_context!
        @team = current_user.team
      end

      def read_only_mode
        true
      end
    end
  end
end
