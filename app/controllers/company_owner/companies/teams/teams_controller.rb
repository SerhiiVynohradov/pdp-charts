module CompanyOwner
  module Companies
    module Teams
      class TeamsController < ApplicationController

        before_action :require_company_owner!
        before_action :set_company
        before_action :authorize_read_company!

        include TeamManagement

        def show
          redirect_to company_owner_company_team_users_path(@company, @team)
        end

        private
        def require_company_owner!
          redirect_to root_path unless current_user&.company_owner?
        end

        def set_company
          @company = current_user.company
        end

        def authorize_read_company!
          redirect_to root_path unless can? :read, @company
        end
      end
    end
  end
end
