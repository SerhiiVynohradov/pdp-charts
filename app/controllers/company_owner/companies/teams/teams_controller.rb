module CompanyOwner
  module Companies
    module Teams
      class TeamsController < CompanyOwner::Companies::BaseController
        include TeamManagement

        def show
          redirect_to company_owner_company_team_users_path(@company, @team)
        end
      end
    end
  end
end
