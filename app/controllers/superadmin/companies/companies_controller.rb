module Superadmin
  module Companies
    class CompaniesController < Superadmin::BaseController
      include CompanyManagement

      def show
        redirect_to superadmin_company_teams_path(@company)
      end
    end
  end
end
