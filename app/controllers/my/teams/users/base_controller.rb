module My
  module Teams
    module Users
      class BaseController < My::Teams::BaseController
        before_action :set_user

        private

        def set_user
          @user = @team.users.find(params[:id])
        end
      end
    end
  end
end
