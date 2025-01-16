module My
  module Companies
    module Teams
      module Users
        class UsersController < ApplicationController
          before_action :authenticate_user!
          before_action :set_company
          before_action :set_team
          before_action :set_users, only: :index
          before_action :set_user, only: :show

          include PdpChartsHelper

          def index
            @chart_data  = chart_data
            @chart_label = chart_label
            render 'shared/users/index', locals: { read_only_mode: true }
          end

          def show
            redirect_to my_company_team_user_items_path(@company, @team, @user)
          end

          private

          def set_company
            @company = Company.find(params[:company_id])
          end

          def set_team
            @team = @company.teams.find(params[:team_id])
          end

          def set_users
            @users = @team.users
          end

          def set_user
            @user = @team.users.find(params[:id])
          end

          def chart_data
            @team.users.map do |u|
              build_pdp_charts_data(u.items, label: u.name)
            end
          end

          def chart_label
            "PDP Chart for team #{@team.name}"
          end
        end
      end
    end
  end
end
