module Manager
  module Teams
    module Users
      class UsersController < Manager::Teams::BaseController
        include UserManagement

        def show
          redirect_to manager_team_user_items_path(@team, @user)
        end
      end
    end
  end
end
