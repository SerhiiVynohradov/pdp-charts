# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :manage, Item, user_id: user.id

    if user.manager?
      can :manage, Item, user_id: user.subordinates_ids
      can :manage, User, team_id: user.managed_team_ids
      can [:read, :update], Team, id: user.managed_team_ids
    end

    if user.company_owner?
      can :manage, Team, company_id: user.company_id
      can :manage, User, company_id: user.company_id
      can :manage, Company, id: user.company_id
    end

    if user.superadmin?
      can :manage, :all
    end
  end
end
