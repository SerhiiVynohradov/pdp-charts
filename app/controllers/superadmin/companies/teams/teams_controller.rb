module Superadmin
  module Companies
    module Teams
      class TeamsController < ApplicationController
        before_action :require_superadmin!
        before_action :set_company
        before_action :authorize_read_company!
        before_action :set_superadmin

        include TeamManagement

        def show
          redirect_to superadmin_company_team_users_path(@company, @team)
        end

        private
        def require_superadmin!
          redirect_to root_path unless current_user&.superadmin?
        end

        def set_company
          @company = Company.find(params[:company_id])
        end

        def authorize_read_company!
          redirect_to root_path unless can? :read, @company
        end

        def set_superadmin
          @superadmin = true
        end
      end
    end
  end
end
