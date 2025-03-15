# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :manage, Item, user_id: user.id

    if user.user?
      can :manage, Event, eventable: user

      if user.team.present?
        if user.team.charts_visible?
          if user.team.company.present?
            if user.team.company.charts_visible?
              can :sidenav, Company, id: user.team.company_id
              can :read, Company, id: user.team.company_id

              can :sidenav, Team, company_id: user.team.company_id

              can :read, Team, company_id: user.team.company_id, charts_visible: true

              can :sidenav_limited, Team, company_id: user.team.company_id, charts_visible: false

              can :read, User do |u|
                (u.team&.company_id == user.team.company_id) &&
                  u.team&.charts_visible?
              end
            else
              can :sidenav, Company, id: user.team.company_id
              can :sidenav, Team, company_id: user.team.company_id
              can :read, Team, id: user.team_id
              can :read, User, team_id: user.team_id
            end
          else
            can :read, Team, id: user.team_id
            can :read, User, team_id: user.team_id
          end
        else
          can :sidenav, Team, id: user.team_id

          if user.team.company.present?
            if user.team.company.charts_visible?
              can :read, Company, id: user.team.company_id
              can :sidenav, Company, id: user.team.company_id

              can :sidenav_limited, Team, id: user.team_id
              can :read, Team, company_id: user.team.company_id, charts_visible: true
            else
              can :sidenav, Company, id: user.team.company_id
              can :sidenav, Team, id: user.team_id
            end
          else
            can :sidenav, Team, id: user.team_id
          end
        end
      else

      end

      can :manage, User, id: user.id
    end

    if user.manager?
      can :manage, Team, id: user.managed_team_ids # todo: restrict only to [:read, :update] - for now it seems too hard for DRY concerns reasons

      can :manage, User, id: user.id # can manage self
      can :manage, User, id: user.subordinates_ids # other team members

      can :manage, Item, user_id: user.subordinates_ids

      can :manage, Event, eventable: user
      can :manage, Event, eventable: user.team
      can :manage, Event, eventable: user.team.users

      if user&.team&.company_id.present?
        can :read, Company, id: user.team.company_id, charts_visible: true
      end
    end

    if user.company_owner?
      # Companies
      can :manage, Company, id: user.company_id

      # Nested teams
      can :manage, Team, company_id: user.company_id

      # Direct users (me for now)
      can :manage, User, company_id: user.company_id

      # Nested team users
      can :manage, User, team_id: user.owned_teams.pluck(:id)

      # Nested Events
      can :manage, Event, eventable: user

      if user.company.present?
        can :manage, Event, eventable: user.company
        can :manage, Event, eventable: user.company.teams
        can :manage, Event, eventable: user.company.teams.map(&:users).flatten
      end
    end

    if user.superadmin?
      can :manage, :all
    end
  end
end
