module CompanyOwner
  module Companies
    module Teams
      class TeamsController < ApplicationController
        include PdpChartsHelper

        before_action :require_company_owner!
        before_action :set_company
        before_action :authorize_company_owner!
        before_action :set_team, only: [:show, :update, :destroy]
        before_action :authorize_manage_team!, only: [:update, :destroy]

        def index
          @company = current_user.company
          @teams = @company.teams

          @chart_data = @teams.map do |t|
            team_users = t.users
            team_items = Item.where(user: team_users)

            build_pdp_charts_data(team_items, label: t.name)
          end

          @chart_label = "PDP Chart for company #{@company.name}"
        end

        def create
          # ...
        end

        def update
          # ...
        end

        def destroy
          # ...
        end

        def show
        end

        def details
          # open manager-like view but from company perspective
        end

        def settings
          # ...
        end

        def recommended
          # ...
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

        def set_team
          @team = @company.teams.find(params[:id])
        end

        def authorize_manage_team!
          redirect_to root_path unless @team.present? && (can? :manage, @team)
        end
      end
    end
  end
end
