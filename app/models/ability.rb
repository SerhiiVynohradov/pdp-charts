# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    if user.manager?
      can :manage, Item, user_id: user.subordinates_ids
    end

    can :manage, Item, user_id: user.id
  end
end
