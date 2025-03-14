module CompanyOwner
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_company_owner_context!

    private
    def set_company_owner_context!
      redirect_to root_path unless current_user.company_owner?
    end
  end
end
