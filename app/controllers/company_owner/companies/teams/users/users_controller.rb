module CompanyOwner
  module Companies
    module Teams
      module Users
        class UsersController < ApplicationController
          before_action :require_company_owner!
          before_action :set_company
          before_action :authorize_manage_company!

          include UserManagement

          def show
            redirect_to company_owner_company_team_user_items_path(@company, @team, @user)
          end

          private
          def require_company_owner!
            redirect_to root_path unless user_signed_in? && current_user.company_owner?
          end

          def set_company
            @company = Company.find(params[:company_id])
          end

          def authorize_manage_company!
            redirect_to root_path unless (can? :manage, @company)
          end

          def set_team
            @team = @company.teams.find(params[:team_id])
          end
        end
      end
    end
  end
end
