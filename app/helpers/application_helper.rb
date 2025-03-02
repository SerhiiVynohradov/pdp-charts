module ApplicationHelper
  def effort_full_label(code)
    case code.to_s
    when "5"
      t('effort.very_hard')
    when "4"
      t('effort.hard')
    when "3"
      t('effort.medium')
    when "2"
      t('effort.easy')
    when "1"
      t('effort.very_easy')
    else
      t('effort.none')
    end
  end

  def breadcrumbs
    crumbs = []

    # Always start with Dashboard
    crumbs << { name: t('breadcrumbs.dashboard'), path: root_path }

    # Determine the namespace and build breadcrumbs accordingly
    case controller_path.split('/').first
    when "manager"
      crumbs += manager_breadcrumbs
    when "company_owner"
      crumbs += company_owner_breadcrumbs
    when "superadmin"
      crumbs += superadmin_breadcrumbs
    when "my"
      crumbs += my_breadcrumbs
    else
      # Default breadcrumbs for other namespaces or main app
      crumbs << { name: controller_name.titleize, path: nil }
      crumbs << { name: action_name.titleize, path: nil } unless action_name == 'index'
    end

    crumbs
  end

  # Sidenav resource links
  def company_path(company)
    if company
      if @superadmin
        superadmin_company_path(company)
      elsif current_user.company_owner?
        company_owner_company_path(company)
      else
        my_company_path(company)
      end
    else
      '#'
    end
  end

  def team_path(company, team)
    if company && team # todo: for manager there may or may not be a company
      if @superadmin
        superadmin_company_team_path(company, team)
      elsif current_user.company_owner?
        company_owner_company_team_path(company, team)
      else
        my_team_path(team)
      end
    else
      '#'
    end
  end

  def user_path(company, team, user)
    if company && team && user

      if @superadmin
        superadmin_company_team_user_path(company, team, user)
      elsif current_user.company_owner?
        company_owner_company_team_user_path(company, team, user)
      elsif current_user.manager?
        manager_team_user_path(team, user)
      else
        my_team_user_path(team, user)
      end

    else
      '#'
    end
  end

  # Sidenav resource settings links
  def company_settings_path(company)
    if company

      if @superadmin
        edit_superadmin_company_path(company)
      elsif current_user.company_owner?
        edit_company_owner_company_path(company)
      elsif current_user.manager?
        edit_manager_company_path(company)
      else
        edit_my_company_path(company)
      end

    else
      '#'
    end
  end

  def team_settings_path(company, team)
    if company && team

      if @superadmin
        edit_superadmin_company_team_path(company, team)
      elsif current_user.company_owner?
        edit_company_owner_company_team_path(company, team)
      elsif current_user.manager?
        edit_manager_team_path(team)
      else
        edit_my_team_path(team)
      end

    else
      '#'
    end

  end

  def user_settings_path(company, team, user)
    if company && team && user

      if @superadmin
        edit_superadmin_company_team_user_path(company, team, user)
      elsif current_user.company_owner?
        edit_company_owner_company_team_user_path(company, team, user)
      elsif current_user.manager?
        edit_manager_team_user_path(team, user)
      else
        edit_my_team_user_path(team, user)
      end

    else
      '#'
    end
  end

  # Sidenav resource events links
  def company_events_path(company)
    if company

      if @superadmin
        superadmin_company_events_path(company)
      elsif current_user.company_owner?
        company_owner_company_events_path(company)
      elsif current_user.manager?
        manager_company_events_path(company)
      else
        my_company_events_path(company)
      end

    else
      '#'
    end

  end

  def team_events_path(company, team)
    if company && team

      if @superadmin
        superadmin_company_team_events_path(company, team)
      elsif current_user.company_owner?
        company_owner_company_team_events_path(company, team)
      elsif current_user.manager?
        manager_team_events_path(team)
      else
        my_team_events_path(team)
      end

    else
      '#'
    end
  end

  def user_events_path(company, team, user)
    if company && team && user

      if @superadmin
        superadmin_company_team_user_events_path(company, team, user)
      elsif current_user.company_owner?
        company_owner_company_team_user_events_path(company, team, user)
      elsif current_user.manager?
        manager_team_user_events_path(team, user)
      else
        my_team_user_events_path(team, user)
      end

    else
      '#'
    end
  end

  def user_path_active?(company, team, user)
    return false unless company && team && user
    request.path.include?(URI.parse(user_path(company, team, user)).path)
  end

  def user_settings_path_active?(company, team, user)
    return false unless company && team && user
    request.path.include?(URI.parse(user_settings_path(company, team, user)).path)
  end

  def user_events_path_active?(company, team, user)
    return false unless company && team && user
    request.path.include?(URI.parse(user_events_path(company, team, user)).path)
  end

  def team_path_open?(company, team)
    return false unless company && team
    request.path.include?(URI.parse(team_path(company, team)).path)
  end

  def company_path_open?(company)
    request.path.include?(URI.parse(company_path(company)).path)
  end

  def company_path_active?(company)
    request.path == URI.parse(company_path(company)).path + '/teams'
  end

  def team_path_active?(company, team)
    return false unless company && team
    request.path == URI.parse(team_path(company, team)).path + '/users'
  end

  def company_settings_path_active?(company)
    request.path.include?(URI.parse(company_settings_path(company)).path)
  end

  def team_settings_path_active?(company, team)
    return false unless company && team
    request.path.include?(URI.parse(team_settings_path(company, team)).path)
  end

  def company_events_path_active?(company)
    request.path.include?(URI.parse(company_events_path(company)).path)
  end

  def team_events_path_active?(company, team)
    return false unless company && team
    request.path.include?(URI.parse(team_events_path(company, team)).path)
  end

  def root_path_active?
    request.path == URI.parse(superadmin_companies_path).path
  end

  private

  def manager_breadcrumbs
    crumbs = []
    # Extract the parts after 'manager'
    parts = controller_path.split('/')[1..-1]

    # Handle Teams
    if parts.include?("teams")
      crumbs << { name: t('breadcrumbs.teams'), path: manager_root_path }
      if @team
        crumbs << { name: @team.name, path: manager_team_path(@team) }
      end
    end

    # Handle Users
    if parts.include?("users")
      crumbs << { name: t('breadcrumbs.users'), path: manager_team_users_path(@team) }
      if @user
        crumbs << { name: @user.name, path: manager_team_user_path(@team, @user) }
      end
    end

    # Handle Items
    if parts.include?("items")
      crumbs << { name: t('breadcrumbs.items'), path: manager_team_user_items_path(@team, @user) }
      if @item
        crumbs << { name: @item.name, path: nil } # Current page, no link
      end
    end

    crumbs
  end

  def company_owner_breadcrumbs
    crumbs = []
    # Extract the parts after 'company_owner'
    parts = controller_path.split('/')[1..-1]

    # Handle Companies
    if parts.include?("companies")
      crumbs << { name: t('breadcrumbs.companies'), path: company_owner_root_path }
      if @company
        crumbs << { name: @company.name, path: company_owner_company_path(@company) }
      end
    end

    # Handle Teams
    if parts.include?("teams")
      crumbs << { name: t('breadcrumbs.teams'), path: company_owner_company_teams_path(@company) }
      if @team
        crumbs << { name: @team.name, path: company_owner_company_team_path(@company, @team) }
      end
    end

    # Handle Users
    if parts.include?("users")
      crumbs << { name: t('breadcrumbs.users'), path: company_owner_company_team_users_path(@company, @team) }
      if @user
        crumbs << { name: @user.name, path: company_owner_company_team_user_path(@company, @team, @user) }
      end
    end

    # Handle Items
    if parts.include?("items")
      crumbs << { name: t('breadcrumbs.items'), path: company_owner_company_team_user_items_path(@company, @team, @user) }
      if @item
        crumbs << { name: @item.name, path: nil } # Current page, no link
      end
    end

    crumbs
  end

  def superadmin_breadcrumbs
    crumbs = []
    # Extract the parts after 'superadmin'
    parts = controller_path.split('/')[1..-1]

    # Handle Companies
    if parts.include?("companies")
      crumbs << { name: t('breadcrumbs.companies'), path: superadmin_companies_path }
      if @company
        crumbs << { name: @company.name, path: superadmin_company_path(@company) }
      end
    end

    # Handle Teams
    if parts.include?("teams")
      crumbs << { name: t('breadcrumbs.teams'), path: superadmin_company_teams_path(@company) }
      if @team
        crumbs << { name: @team.name, path: superadmin_company_team_path(@company, @team) }
      end
    end

    # Handle Users
    if parts.include?("users")
      crumbs << { name: t('breadcrumbs.users'), path: superadmin_company_team_users_path(@company, @team) }
      if @user
        crumbs << { name: @user.name, path: superadmin_company_team_user_path(@company, @team, @user) }
      end
    end

    # Handle Items
    if parts.include?("items")
      crumbs << { name: t('breadcrumbs.items'), path: superadmin_company_team_user_items_path(@company, @team, @user) }
      if @item
        crumbs << { name: @item.name, path: nil } # Current page, no link
      end
    end

    crumbs
  end

  def my_breadcrumbs
    crumbs = []
    parts  = controller_path.split('/')[1..-1] # всё, что после "my"

    if parts.include?("companies")
      crumbs << { name: t('breadcrumbs.my_companies'), path: my_root_path }
      if @company
        crumbs << { name: @company.name, path: my_company_path(@company) }
      end

      if parts.include?("teams")
        crumbs << { name: t('breadcrumbs.teams'), path: my_company_teams_path(@company) }
        if @team
          crumbs << { name: @team.name, path: my_company_team_path(@company, @team) }
        end

        if parts.include?("users")
          crumbs << { name: t('breadcrumbs.users'), path: my_company_team_users_path(@company, @team) }
          if @user
            crumbs << { name: @user.name, path: my_company_team_user_path(@company, @team, @user) }
          end

          if parts.include?("items")
            crumbs << { name: t('breadcrumbs.items'), path: my_company_team_user_items_path(@company, @team, @user) }
            if @item
              crumbs << { name: @item.name, path: nil }
            end
          end
        end
      end

    elsif parts.include?("teams")
      crumbs << { name: t('breadcrumbs.my_teams'), path: my_root_path }
      if @team
        crumbs << { name: @team.name, path: my_team_path(@team) }
      end

      if parts.include?("users")
        crumbs << { name: t('breadcrumbs.users'), path: my_team_users_path(@team) }
        if @user
          crumbs << { name: @user.name, path: my_team_user_path(@team, @user) }
        end

        if parts.include?("items")
          crumbs << { name: t('breadcrumbs.items'), path: my_team_user_items_path(@team, @user) }
          if @item
            crumbs << { name: @item.name, path: nil }
          end
        end
      end

    elsif parts.include?("items")
      crumbs << { name: t('breadcrumbs.my_items'), path: my_items_path }
      if @item
        crumbs << { name: @item.name, path: nil }
      end
    end

    crumbs
  end
end
