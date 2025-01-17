module My
  class RecommendedItemsController < ApplicationController
    include RecommendedItemsFetching

    before_action :set_user

    private

    def set_user
      redirect_to root_path unless user_signed_in?

      @user = current_user
    end
  end
end
