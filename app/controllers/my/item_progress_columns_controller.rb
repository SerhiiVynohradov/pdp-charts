module My
  class ItemProgressColumnsController < ApplicationController
    before_action :authenticate_user!

    include ItemProgressColumnManagement

    private
    def set_user
      @user = current_user
    end
  end
end
