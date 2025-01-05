module ApplicationHelper
  def effort_full_label(code)
    case code.to_s
    when "5"
      "5 - Very Hard (10+ full-time days)"
    when "4"
      "4 - Hard (5-10 full-time days)"
    when "3"
      "3 - Medium (3-5 full-time days)"
    when "2"
      "2 - Easy (2-3 full-time days)"
    when "1"
      "1 - Very Easy (<1 full-time day)"
    else
      "-"
    end
  end


  def breadcrumbs
    crumbs = []

    # Always start with Dashboard
    crumbs << { name: "Dashboard", path: root_path }

    # Determine the namespace and build breadcrumbs accordingly
    case controller_path.split('/').first
    when "manager"
      crumbs += manager_breadcrumbs
    when "company_owner"
      crumbs += company_owner_breadcrumbs
    when "my"
      crumbs += my_breadcrumbs
    else
      # Default breadcrumbs for other namespaces or main app
      crumbs << { name: controller_name.titleize, path: nil }
      crumbs << { name: action_name.titleize, path: nil } unless action_name == 'index'
    end

    # Render the breadcrumbs
    content_tag(:nav, class: "breadcrumbs flex items-center space-x-2 text-sm text-gray-400") do
      crumbs.map.with_index do |crumb, index|
        if crumb[:path]
          link_to(crumb[:name], crumb[:path], class: "text-blue-500 hover:underline")
        else
          content_tag(:span, crumb[:name], class: "current text-gray-200")
        end
      end.join(" / ").html_safe
    end
  end

  private

  def manager_breadcrumbs
    crumbs = []
    # Extract the parts after 'manager'
    parts = controller_path.split('/')[1..-1]

    # Handle Teams
    if parts.include?("teams")
      crumbs << { name: "Teams", path: manager_root_path }
      if @team
        crumbs << { name: @team.name, path: manager_team_path(@team) }
      end
    end

    # Handle Users
    if parts.include?("users")
      crumbs << { name: "Users", path: manager_team_users_path(@team) }
      if @user
        crumbs << { name: @user.name, path: manager_team_user_path(@team, @user) }
      end
    end

    # Handle Items
    if parts.include?("items")
      crumbs << { name: "Items", path: manager_team_user_items_path(@team, @user) }
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
      crumbs << { name: "Companies", path: company_owner_root_path }
      if @team
        crumbs << { name: @company.name, path: company_owner_company_path(@team) }
      end
    end

    # Handle Teams
    if parts.include?("teams")
      crumbs << { name: "Teams", path: company_owner_company_teams_path(@company) }
      if @team
        crumbs << { name: @team.name, path: company_owner_company_team_path(@company, @team) }
      end
    end

    # Handle Users
    if parts.include?("users")
      crumbs << { name: "Users", path: company_owner_company_team_users_path(@company, @team) }
      if @user
        crumbs << { name: @user.name, path: company_owner_company_team_user_path(@company, @team, @user) }
      end
    end

    # Handle Items
    if parts.include?("items")
      crumbs << { name: "Items", path: company_owner_company_team_user_items_path(@company, @team, @user) }
      if @item
        crumbs << { name: @item.name, path: nil } # Current page, no link
      end
    end

    crumbs
  end

  def my_breadcrumbs
    crumbs = []
    # Extract the parts after 'my'
    parts = controller_path.split('/')[1..-1]

    # Handle My Items
    if parts.include?("items")
      crumbs << { name: "My Items", path: my_items_path }
      if @item
        crumbs << { name: @item.name, path: nil } # Current page, no link
      end
    end

    crumbs
  end
end
