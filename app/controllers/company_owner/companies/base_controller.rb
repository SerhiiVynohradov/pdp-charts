module CompanyOwner
  module Companies
    class BaseController < CompanyOwner::BaseController
      before_action :set_company_context!

      private
      def set_company_context!
        @company = current_user.company
        redirect_to root_path unless can? :read, @company
      end
    end
  end
end
