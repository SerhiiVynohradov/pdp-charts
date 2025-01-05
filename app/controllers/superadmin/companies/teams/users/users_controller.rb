module Superadmin
  module Companies
    module Teams
      module Users
        class UsersController < ApplicationController
          before_action :require_superadmin!
          before_action :set_company
          before_action :authorize_manage_company!
          before_action :set_superadmin

          include UserManagement

          def show
            redirect_to superadmin_company_team_user_items_path(@company, @team, @user)
          end

          private
          def require_superadmin!
            redirect_to root_path unless user_signed_in? && current_user.superadmin?
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

          def set_superadmin
            @superadmin = true
          end
        end
      end
    end
  end
end
