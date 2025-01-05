module CompanyOwner
  class DashboardsController < ApplicationController
    before_action :require_company_owner!

    def index
      redirect_to company_owner_company_path(current_user.company)
    end

    def charts
      # build multi-line chart with one line per team, or one line per user
    end

    private
    def require_company_owner!
      redirect_to root_path unless current_user&.company_owner?
    end
  end
end
