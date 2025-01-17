module CompanyOwner
  module Companies
    class RecommendedItemsController < ApplicationController
      before_action :set_context!

      include RecommendedItemsManagement

      private
      def set_context!
        redirect_to root_path unless user_signed_in? && current_user.company_owner?

        @company = Company.find(params[:company_id])

        redirect_to root_path unless (can? :manage, @company)
      end
    end
  end
end
