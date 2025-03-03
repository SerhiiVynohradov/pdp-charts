module Superadmin
  module Companies
    module Teams
      module Users
        class BaseController < Superadmin::Companies::Teams::BaseController
          before_action :set_user_context!

          private

          def set_user_context!
            @user = @team.users.find(params[:user_id])
            redirect_to root_path unless can? :manage, @user
          end
        end
      end
    end
  end
end
