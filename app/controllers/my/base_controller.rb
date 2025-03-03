module My
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_context!

    private

    def set_context!
      @sidebar_context = if current_user.superadmin?
                           :superadmin
                         elsif current_user.company_owner?
                           :company_owner
                         elsif current_user.manager?
                           :manager
                         else
                           :user
                         end

      @user = current_user

      redirect_to root_path unless can? :read, @user
    end

    def read_only_mode
      true
    end
  end
end
