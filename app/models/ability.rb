# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :manage, Item, user_id: user.id

    if user.user?
      can :manage, User, id: user.id

      can :manage, Event, eventable: user
    end

    if user.manager?
      can :manage, Team, id: user.managed_team_ids # todo: restrict only to [:read, :update] - for now it seems too hard for DRY concerns reasons

      can :manage, User, id: user.id # can manage self
      can :manage, User, id: user.subordinates_ids # other team members

      can :manage, Item, user_id: user.subordinates_ids

      can :manage, Event, eventable: user
      can :manage, Event, eventable: user.team
      can :manage, Event, eventable: user.team.users
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
      can :manage, Event, eventable: user.company
      can :manage, Event, eventable: user.company.teams
      can :manage, Event, eventable: user.company.teams.map(&:users).flatten
    end

    if user.superadmin?
      can :manage, :all
    end
  end
end
