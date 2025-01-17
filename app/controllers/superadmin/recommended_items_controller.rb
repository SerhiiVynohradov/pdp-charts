module Superadmin
  class RecommendedItemsController < ApplicationController
    before_action :set_context!

    include RecommendedItemsManagement

    private
    def set_context!
      redirect_to root_path unless current_user.superadmin?
      @superadmin = true
    end
  end
end
