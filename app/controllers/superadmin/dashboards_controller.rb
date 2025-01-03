module Superadmin
  class DashboardsController < ApplicationController
    before_action :require_superadmin!

    def index
      # ...
    end

    def all_companies_chart
      # build chart with one line per company
    end

    private
    def require_superadmin!
      redirect_to root_path unless current_user&.superadmin?
    end
  end
end
