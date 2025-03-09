module Superadmin
  module Companies
    module Teams
      class BaseController < Superadmin::Companies::BaseController
        before_action :set_team_context!

        def set_team_context!
          if params[:team_id] == 'na'
            @team = nil
          else
            if @company.nil?
              @team = Team.find(params[:team_id])
            else
              @team = @company.teams.find(params[:team_id])
            end

            redirect_to root_path unless can? :manage, @team
          end
        end
      end
    end
  end
end
