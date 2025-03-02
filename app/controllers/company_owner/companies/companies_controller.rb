module CompanyOwner
  module Companies
    class CompaniesController < ApplicationController
      before_action :require_company_owner!
      before_action :set_company, only: [:show, :edit, :update]
      before_action :authorize_company_owner!

      def show
        redirect_to company_owner_company_teams_path(@company)
      end

      def edit

      end

      def update
        if @company.update(company_params)
          redirect_to edit_company_owner_company_path(current_user.company), notice: I18n.t('messages.company.updated_successfully')
        else
          render :edit
        end
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

      def company_params
        params.require(:company).permit(:name, :charts_visible)
      end
    end
  end
end
