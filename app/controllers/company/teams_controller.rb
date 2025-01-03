module Company
  class TeamsController < ApplicationController
    before_action :require_company_owner!

    def index
      @company = current_user.company
      @teams = @company.teams
    end

    def create
      # ...
    end

    def update
      # ...
    end

    def destroy
      # ...
    end

    def details
      # open manager-like view but from company perspective
    end

    def settings
      # ...
    end

    def recommended
      # ...
    end
  end
end
