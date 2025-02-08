module My
  module Teams
    module Users
      class UsersController < ApplicationController
        before_action :authenticate_user!
        before_action :set_team
        before_action :set_user, only: :show

        include PdpChartsHelper

        def index
          @users = @team.users
          @chart_data = chart_data_index
          @chart_label = chart_label_index
          @events = set_events

          render 'shared/users/index', locals: { read_only_mode: true }
        end

        def show
          redirect_to my_team_user_items_path(@team, @user)
        end

        private

        def set_team
          @team = current_user.team
        end

        def set_user
          @user = @team.users.find(params[:id])
        end

        def chart_data_index
          data = @team.users.map do |u|
            build_pdp_charts_data(u.items, label: u.name)
          end

          data << build_pdp_constant_line_data(
            @team&.effort_line || 1000,
            label: 'Лінія ризику вигоряння',
            chart_type: :effort
          )
          data << build_pdp_constant_line_data(
            @team&.wa_line || 40,
            label: 'Лінія зміни пріорітетів',
            chart_type: :wa
          )
          data << build_pdp_constant_line_data(
            @team&.items_line || 5,
            label: 'Лінія розпилення',
            chart_type: :items
          )

          data
        end

        def chart_label_index
          I18n.t('labels.pdp_chart.for_team', team: @team.name)
        end

        def read_only_mode
          true
        end
      end
    end
  end
end
