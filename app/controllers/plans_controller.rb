class PlansController < ApplicationController
  before_action :authenticate_user!

  def upgrade
    # Рендерим страницу с вариантами (User / Manager / Owner)
  end


  def update_role
    plan = params[:plan]

    # TODO:
    # Case 1: User becomes Manager
    # - is a manager of his own team
    # - still uses the other team as a user
    # Case 2: Manager becomes Owner
    # - creates his own company
    # - still manages the other company's team
    # Case 3: User becomes Owner
    # - creates his own company
    # - still has his own items (without a team)
    # Case 4: Manager becomes User
    # - no longer is a manager of his team? Orphan team?
    # Case 5: Owner becomes User
    # - no longer has a company? Orphan company?
    # Case 6: Owner becomes Manager
    # - no longer has a company? Orphan company?
    # - is a manager of his own team
    #
    # This is at least HABTM + pay per company/team created.
    # It's not a simple role change.

    if current_user.update(role: plan)
      if current_user.manager? && current_user.team.blank?
        redirect_to new_team_path
      elsif current_user.company_owner? && current_user.company.blank?
        redirect_to new_company_path
      else
        redirect_to root_path, notice: I18n.t('messages.plan.updated_successfully')
      end
    else
      redirect_to upgrade_plans_path, I18n.t('messages.something_went_wrong')
    end
  end
end
