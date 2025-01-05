module CompanyOwner
  module Companies
    module Teams
      class TeamsController < ApplicationController
        include TeamManagement

        before_action :require_company_owner!
        before_action :set_company
        before_action :authorize_read_company!

        before_action :set_teams, only: [:index]

        before_action :set_team, only: [:show, :update, :destroy]
        before_action :authorize_manage_team!, only: [:show, :update, :destroy]

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

        def set_team
          @team = @company.teams.find(params[:id])
        end

        def set_teams
          @teams = @company.teams
        end

        def authorize_manage_team!
          redirect_to root_path unless @team.present? && (can? :manage, @team)
        end
      end
    end
  end
end
