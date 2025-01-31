class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :create_team_or_company
  before_action :redirect_to_www

  private

  def create_team_or_company
    if user_signed_in?
      if current_user.manager? && current_user.team.blank? && !request.path.include?("teams")
        redirect_to new_team_path
      elsif current_user.company_owner? && current_user.company.blank? && !request.path.include?("companies")
        redirect_to new_company_path
      elsif current_user.manager? && current_user.team.present? && request.path == '/'
        redirect_to manager_team_path(current_user.team)
      elsif current_user.company_owner? && current_user.company.present? && request.path == '/'
        redirect_to company_owner_company_path(current_user.company)
      elsif current_user.superadmin? && request.path == '/'
        redirect_to superadmin_companies_path
      elsif current_user.user? && request.path == '/'
        redirect_to my_items_path
      end
    end
  end

  def redirect_to_www
    if request.host == 'pdpcharts.com'
      redirect_to("#{request.protocol}www.pdpcharts.com#{request.fullpath}", status: 301)
    end
  end
end
