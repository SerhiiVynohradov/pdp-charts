module Manager
  module Teams
    module Users
      class BaseController < Manager::Teams::BaseController
        before_action :set_user_context!

        private
        def set_user_context!
          @user = @team.users.find(params[:user_id])
          redirect_to root_path unless @user.present? && (can? :manage, @user)
        end
      end
    end
  end
end
