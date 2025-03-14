module Manager
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_manager_context!

    private
    def set_manager_context!
      redirect_to root_path unless current_user.manager?
    end
  end
end
