module My
  module Teams
    class BaseController < My::BaseController
      before_action :set_team_context!

      private

      def set_team_context!
        @team = current_user.team
      end
    end
  end
end
