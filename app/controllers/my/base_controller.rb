module My
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_my_context!

    private

    def set_my_context!
      @user = current_user

      redirect_to root_path unless can? :read, @user
    end

    # todo: fix with smth better
    def read_only_mode
      true
    end
  end
end
