module Superadmin
  module Companies
    module Teams
      class BaseController < Superadmin::Companies::BaseController
        before_action :set_team_context!

        def set_team_context!
          @team = @company.teams.find(params[:team_id])
          redirect_to root_path unless can? :manage, @team
        end
      end
    end
  end
end
