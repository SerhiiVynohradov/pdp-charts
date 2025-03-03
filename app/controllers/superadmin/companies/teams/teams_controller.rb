module Superadmin
  module Companies
    module Teams
      class TeamsController < Superadmin::Companies::BaseController
        include TeamManagement

        def show
          redirect_to superadmin_company_team_users_path(@company, @team)
        end
      end
    end
  end
end
