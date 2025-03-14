module My
  module Companies
    module Teams
      class TeamsController < My::Companies::BaseController
        before_action :set_teams, only: :index
        before_action :set_team, only: :show

        include PdpChartsHelper

        def index
          @chart_data  = chart_data
          @chart_label = chart_label
          render 'shared/teams/index', locals: { read_only_mode: true }
        end

        def show
          redirect_to my_company_team_users_path(@company, @team)
        end

        private

        def set_teams
          @teams = @company.teams
        end

        def set_team
          @team = @company.teams.find(params[:id])
        end

        def chart_data
          @teams.map do |t|
            team_users = t.users
            team_items = Item.where(user: team_users)

            build_pdp_charts_data(team_items, label: t.name)
          end
        end

        def chart_label
          I18n.t('labels.pdp_chart.for_company', company: @company.name)
        end
      end
    end
  end
end
