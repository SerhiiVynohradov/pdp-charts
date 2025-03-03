module My
  module Teams
    class TeamsController < My::Teams::BaseController
      def show
        redirect_to my_team_users_path(@team)
      end
    end
  end
end
