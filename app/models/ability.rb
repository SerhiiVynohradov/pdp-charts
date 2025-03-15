class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    # Обычные предметы
    can :manage, Item, user_id: user.id

    # -----------------------------------
    # ОБЫЧНЫЙ ПОЛЬЗОВАТЕЛЬ
    # -----------------------------------
    if user.user?
      can :manage, Event, eventable: user

      if user.team.present?
        if user.team.charts_visible?
          if user.team.company.present?
            if user.team.company.charts_visible?
              # company charts on
              can :sidenav, Company, id: user.team.company_id
              can :read, Company, id: user.team.company_id

              can :sidenav, Team, company_id: user.team.company_id
              can :read, Team, company_id: user.team.company_id, charts_visible: true

              # Команды, у которых charts_off -> показываем только ограниченно
              can :sidenav_limited, Team, company_id: user.team.company_id, charts_visible: false

              # Пользователей из команд charts_on можно читать
              can :read, User do |u|
                (u.team&.company_id == user.team.company_id) &&
                  u.team&.charts_visible?
              end
            else
              # company charts off
              can :sidenav, Company, id: user.team.company_id
              can :sidenav, Team, company_id: user.team.company_id
              can :read, Team, id: user.team_id
              can :read, User, team_id: user.team_id
            end
          else
            # company absent
            can :read, Team, id: user.team_id
            can :read, User, team_id: user.team_id
          end
        else
          # team charts off
          can :sidenav, Team, id: user.team_id

          if user.team.company.present?
            if user.team.company.charts_visible?
              # company on, team off
              can :read, Company, id: user.team.company_id
              can :sidenav, Company, id: user.team.company_id

              # Команду user.team видим только ограниченно
              can :sidenav_limited, Team, id: user.team_id

              # Другие команды компании, если charts_visible = true, можно читать
              can :read, Team, company_id: user.team.company_id, charts_visible: true
            else
              # company off, team off
              can :sidenav, Company, id: user.team.company_id
              can :sidenav, Team, id: user.team_id
            end
          else
            # нет компании, но команда off
            can :sidenav, Team, id: user.team_id
          end
        end
      else
        # no team
        # Пользователь без команды ничего не видит, кроме своих
      end

      # Всегда можно управлять собой
      can :manage, User, id: user.id
    end

    # -----------------------------------
    # МЕНЕДЖЕР
    # -----------------------------------
    if user.manager?
      # Может управлять командой, которой управляет
      can :manage, Team, id: user.managed_team_ids

      # Может управлять собой
      can :manage, User, id: user.id
      # Может управлять пользователями, которые ему подчиняются
      can :manage, User, id: user.subordinates_ids

      # Может управлять айтемами своих подчинённых
      can :manage, Item, user_id: user.subordinates_ids

      # События, связанные с ним и его командой
      can :manage, Event, eventable: user
      can :manage, Event, eventable: user.team
      can :manage, Event, eventable: user.team.users

      # Если у нас есть компания
      if user.team&.company.present?
        # Менеджер видит эту компанию в сайдбаре (read/sidenav),
        # но если компания charts_off, то ограничиваем логику
        if user.team.company.charts_visible?
          can :read, Company, id: user.team.company_id
          can :sidenav, Company, id: user.team.company_id

          # Менеджер может видеть все команды (названия) этой компании
          can :sidenav, Team, company_id: user.team.company_id
          # Но полноценно "read" только те, у кого charts_visible = true
          can :read, Team, company_id: user.team.company_id, charts_visible: true

          # Свою команду (даже если у неё off) – всё равно manage
          can :manage, Team, id: user.team_id

          # Юзеры из видимых команд
          can :read, User do |u|
            (u.team&.company_id == user.team.company_id) &&
              (u.team&.charts_visible? || u.team_id == user.team_id)
          end
        else
          # company off
          can :sidenav, Company, id: user.team.company_id

          # Менеджер всё равно manage свою команду
          can :manage, Team, id: user.team_id

          # Другие команды компании не видим
          can :sidenav, Team, id: user.team_id

          # Свои юзеры
          can :manage, User, team_id: user.team_id
        end
      end
    end

    # -----------------------------------
    # COMPANY OWNER
    # -----------------------------------
    if user.company_owner?
      # Может управлять своей компанией
      can :manage, Company, id: user.company_id

      # Все команды своей компании
      can :manage, Team, company_id: user.company_id

      # Всех пользователей этой компании
      can :manage, User, company_id: user.company_id

      # Nested team users
      can :manage, User, team_id: user.owned_teams.pluck(:id)

      # События
      can :manage, Event, eventable: user
      if user.company.present?
        can :manage, Event, eventable: user.company
        can :manage, Event, eventable: user.company.teams
        can :manage, Event, eventable: user.company.teams.map(&:users).flatten
      end
    end

    # -----------------------------------
    # SUPERADMIN
    # -----------------------------------
    if user.superadmin?
      can :manage, :all
    end
  end
end
