module CompanyOwner
  module Companies
    class CompaniesController < ApplicationController
      before_action :require_company_owner!
      before_action :set_company, only: [:show]
      before_action :authorize_company_owner!

      def show
        redirect_to company_owner_company_teams_path(@company)
      end

      private
      def require_company_owner!
        redirect_to root_path unless current_user&.company_owner?
      end

      def set_company
        @company = current_user.company
      end

      def authorize_company_owner!
        redirect_to root_path unless can? :read, @company
      end
    end
  end
end
