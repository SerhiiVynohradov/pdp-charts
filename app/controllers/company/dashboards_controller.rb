module Company
  class DashboardsController < ApplicationController
    before_action :require_company_owner!

    def show
      # show a “list of teams”, or a “company summary”
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
