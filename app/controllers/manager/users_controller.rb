module Manager
  class UsersController < ApplicationController
    before_action :require_manager!

    def index
      @team = current_user.managed_teams.find(params[:team_id])
      @users = @team.users
    end

    def show
      @team = current_user.managed_teams.find(params[:team_id])
      @user = @team.users.find(params[:id])
      @items = @user.items.order(created_at: :desc)
      @chart_data = [build_pdp_charts_data(@items, label: "My Items")]
      @chart_label = "My PDP Chart"
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

    def pause
      # ...
    end
  end
end
