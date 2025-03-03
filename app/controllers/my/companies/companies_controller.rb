module My
  module Companies
    class CompaniesController < My::BaseController
      before_action :authenticate_user!
      before_action :set_company, only: :show

      def show
        redirect_to my_company_teams_path(@company)
      end

      private

      def set_company
        @company = Company.find(params[:id])
      end
    end
  end
end
