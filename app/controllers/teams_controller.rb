class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_manager_without_team, only: [:new, :create]

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      current_user.update(team_id: @team.id)
      redirect_to manager_team_path(@team), notice: "Team created successfully!"
    else
      render :new
    end
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end

  def ensure_manager_without_team
    unless current_user.manager? && current_user.team.nil?
      redirect_to root_path, alert: "You are not allowed to create a team."
    end
  end
end
