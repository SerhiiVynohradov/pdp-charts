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

    # Manager Namespace
    if controller_path.start_with?("manager/")
      # Split the controller path into its components
      parts = controller_path.split("/")[1..-1] # Removes "manager/"

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

    # My Namespace
    elsif controller_path.start_with?("my/")
      # Split the controller path into its components
      parts = controller_path.split("/")[1..-1] # Removes "my/"

      # Handle My Items
      if parts.include?("items")
        crumbs << { name: "My Items", path: my_items_path }
        if @item
          crumbs << { name: @item.name, path: nil } # Current page, no link
        end
      end
    end

    # Render the breadcrumbs
    content_tag(:nav, class: "breadcrumbs flex space-x-2 text-sm text-gray-500") do
      crumbs.map.with_index do |crumb, index|
        if crumb[:path]
          link_to(crumb[:name], crumb[:path], class: "text-blue-600 hover:underline")
        else
          content_tag(:span, crumb[:name], class: "current")
        end
      end.join(" / ").html_safe
    end
  end
end
