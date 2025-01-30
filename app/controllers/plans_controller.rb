class PlansController < ApplicationController
  before_action :authenticate_user!

  def upgrade
    # Рендерим страницу с вариантами (User / Manager / Owner)
  end


  def update_role
    plan = params[:plan]
    if current_user.update(role: plan)
      if current_user.manager? && current_user.team.blank?
        redirect_to new_team_path
      elsif current_user.company_owner? && current_user.company.blank?
        redirect_to new_company_path
      else
        redirect_to root_path, notice: "Your plan has been updated."
      end
    else
      redirect_to upgrade_plans_path, alert: "Something went wrong."
    end
  end
end
