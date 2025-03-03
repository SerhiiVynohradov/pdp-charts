module My
  module Companies
    class BaseController < My::BaseController
      before_action :set_company_context!

      private

      def set_company_context!
        @company = Company.find(params[:company_id])
        redirect_to root_path unless can? :read, @company
      end
    end
  end
end
