class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :set_sidenav_context!
  before_action :create_team_or_company
  before_action :redirect_to_www
  before_action :set_locale

  private

  def create_team_or_company
    if user_signed_in? && !request.path.include?("sign_out")
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


  def set_sidenav_context!
    return unless user_signed_in?

    if current_user.superadmin?
      @sidebar_context = :superadmin
      @sidebar_companies = Company.all
      @search_companies = Company.all
      @search_teams = Team.all
      @search_users = User.all

    elsif current_user.company_owner?
      @sidebar_context = :company_owner

      # Владелец компании
      if current_user.company.present?
        @sidebar_companies = [current_user.company]
        @search_companies = [current_user.company]
        @search_teams = current_user.company.teams
        @search_users = current_user.company.teams.map(&:users).flatten
        @orphan_teams = []
        @orphan_users = [current_user]
      else
        @sidebar_companies = []
        @search_companies = []
        @search_teams = []
        @search_users = []
        @orphan_teams = []
        @orphan_users = [current_user]
      end

    elsif current_user.manager?
      @sidebar_context = :manager

      # Логика для менеджера
      if current_user.team.present?
        if current_user.team.company.present?
          @sidebar_companies = [current_user.team.company]
          @orphan_teams = []
          @orphan_users = []

          # Менеджер всегда видит свою команду (полностью)
          # Добавим базовый список
          @search_companies = [current_user.team.company]
          @search_teams = [current_user.team]
          @search_users = current_user.team.users

          # Если у компании charts_on, то позволяем видеть остальные команды (только если charts_visible)
          if current_user.team.company.charts_visible?
            all_teams = current_user.team.company.teams
            @search_teams = all_teams
            # Юзеры из команд, которые charts_visible = true
            visible_teams = all_teams.where(charts_visible: true)
            # Объединяем с собственной командой менеджера, т.к. он видит её всегда
            all_manager_users = (current_user.team.users + visible_teams.map(&:users).flatten).uniq
            @search_users = all_manager_users
          end
        else
          # company absent?
          @sidebar_companies = []
          @orphan_teams = [current_user.team]
          @orphan_users = []
          @search_companies = []
          @search_teams = [current_user.team]
          @search_users = current_user.team.users
        end
      else
        # manager без команды
        @sidebar_companies = []
        @orphan_teams = []
        @orphan_users = []
        @search_companies = []
        @search_teams = []
        @search_users = []
      end

    else
      # ---------------------------------
      # Обычный user
      # ---------------------------------
      @sidebar_context = :user

      if current_user.team.present?
        if current_user.team.company.present?
          if current_user.team.company.charts_visible?
            @sidebar_companies = [current_user.team.company]
            @orphan_teams = []
            @orphan_users = []

            @search_companies = [current_user.team.company]
            all_teams = current_user.team.company.teams
            visible_teams = all_teams.where(charts_visible: true)

            @search_teams = all_teams
            @search_users = visible_teams.map(&:users).flatten
          else
            @sidebar_companies = [current_user.team.company]
            @orphan_teams = []
            @orphan_users = []

            @search_companies = [current_user.team.company]
            @search_teams = [current_user.team]
            if current_user.team.charts_visible?
              @search_users = current_user.team.users
            else
              @search_users = [current_user]
            end
          end
        else
          if current_user.team.charts_visible?
            @sidebar_companies = []

            @orphan_teams = [current_user.team]
            @orphan_users = []

            @search_companies = []
            @search_teams = [current_user.team]
            @search_users = current_user.team.users
          else
            @sidebar_companies = []
            @orphan_teams = [current_user.team]
            @orphan_users = []

            @search_companies = []
            @search_teams = [current_user.team]
            @search_users = [current_user]
          end
        end
      else
        @sidebar_companies = []
        @orphan_teams = []
        @orphan_users = []

        @search_companies = []
        @search_teams = []
        @search_users = []
      end
    end
  end

  def redirect_to_www
    if request.host == 'pdpcharts.com'
      redirect_to("https://www.pdpcharts.com#{request.fullpath}", status: 301, allow_other_host: true)
    end
  end

  def set_locale
    if params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
      session[:locale] = I18n.locale
    else
      I18n.locale = session[:locale] || I18n.default_locale
    end
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge(options)
  end

  def set_events
    # , current_user
    [@company, @team, @user].compact.map(&:events).flatten.uniq
  end

end
