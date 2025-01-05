module Superadmin
  module Companies
    class CompaniesController < ApplicationController
      before_action :require_superadmin!

      include CompanyManagement

      def show
        redirect_to superadmin_company_teams_path(@company)
      end

      private
      def require_superadmin!
        redirect_to root_path unless current_user&.superadmin?
      end
    end
  end
end
