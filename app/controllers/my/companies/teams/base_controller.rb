module My
  module Companies
    module Teams
      class BaseController < My::Companies::BaseController
        before_action :set_team_context!

        private

        def set_team_context!
          @team = @company.teams.find(params[:team_id])
          redirect_to root_path unless can? :read, @team
        end
      end
    end
  end
end
