module Superadmin
  module Companies
    module Teams
      module Users
        class UsersController < Superadmin::Companies::Teams::BaseController
          include UserManagement

          def show
            redirect_to superadmin_company_team_user_items_path(@company, @team, @user)
          end
        end
      end
    end
  end
end
