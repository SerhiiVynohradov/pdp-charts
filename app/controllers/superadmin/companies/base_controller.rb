module Superadmin
  module Companies
    class BaseController < Superadmin::BaseController
      before_action :set_company_context!

      private
      def set_company_context!
        id = params[:company_id]
        if id != 'na'
          @company = Company.find(params[:company_id])
          redirect_to root_path unless can? :manage, @company
        else
          @company = nil
        end
      end
    end
  end
end
