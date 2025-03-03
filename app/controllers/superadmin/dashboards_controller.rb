module Superadmin
  class DashboardsController < Superadmin::BaseController
    def index
      redirect_to company_owner_company_path(current_user.company)
    end

    def charts
      # build multi-line chart with one line per team, or one line per user
    end
  end
end
