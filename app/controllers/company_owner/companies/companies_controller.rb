module CompanyOwner
  module Companies
    class CompaniesController < CompanyOwner::Companies::BaseController
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
      def company_params
        params.require(:company).permit(:name, :charts_visible)
      end
    end
  end
end
