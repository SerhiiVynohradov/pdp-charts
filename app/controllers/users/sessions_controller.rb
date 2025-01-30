class Users::SessionsController < Devise::SessionsController

  protected

  def after_sign_in_path_for(resource)
    if resource.manager? && resource.team.blank?
      new_team_path
    elsif resource.company_owner? && resource.company.blank?
      new_company_path
    else
      root_path
    end
  end
end
