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
          @new_team_form_url = company_owner_company_teams_path(@company)

          @chart_data = @teams.map do |t|
            team_users = t.users
            team_items = Item.where(user: team_users)

            build_pdp_charts_data(team_items, label: t.name)
          end

          @chart_label = "PDP Chart for company #{@company.name}"
        end

        def create
          @team = @company.teams.build(team_params)
          @new_team_form_url = company_owner_company_teams_path(@company)

          if @team.save
            respond_to do |format|
              format.turbo_stream { render partial: "shared/teams/create", locals: { team: @team }, formats: [:turbo_stream] }
              format.html { redirect_to my_items_path, notice: "Item created." }
            end
          else
            respond_to do |format|
              format.turbo_stream { render :new, status: :unprocessable_entity }
              format.html { render :new, status: :unprocessable_entity }
            end
          end
        end

        def update
          # ...
        end

        def destroy
          respond_to do |format|
            format.turbo_stream { render partial: "shared/teams/destroy", locals: { team: @team }, formats: [:turbo_stream] }
            format.html { redirect_to my_items_path, notice: "Item deleted." }
          end
          @team.destroy
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

        def team_params
          params.require(:team).permit(
            :name
          )
        end
      end
    end
  end
end
