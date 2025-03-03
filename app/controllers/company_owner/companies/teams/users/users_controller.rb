module CompanyOwner
  module Companies
    module Teams
      module Users
        class UsersController < CompanyOwner::Companies::Teams::BaseController
          include UserManagement

          def show
            redirect_to company_owner_company_team_user_items_path(@company, @team, @user)
          end
        end
      end
    end
  end
end
