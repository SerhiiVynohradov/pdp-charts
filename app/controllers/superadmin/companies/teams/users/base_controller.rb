module Superadmin
  module Companies
    module Teams
      module Users
        class BaseController < Superadmin::Companies::Teams::BaseController
          before_action :set_user_context!

          private

          def set_user_context!
            if @team.nil?
              @user = User.find(params[:user_id])
            else
              @user = @team.users.find(params[:user_id])
            end

            redirect_to root_path unless can? :manage, @user
          end
        end
      end
    end
  end
end
