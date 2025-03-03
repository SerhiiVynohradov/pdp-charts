module Superadmin
  module Companies
    class BaseController < Superadmin::BaseController
      before_action :set_company_context!

      private
      def set_company_context!
        @company = Company.find(params[:company_id])
        redirect_to root_path unless can? :manage, @company
      end
    end
  end
end
