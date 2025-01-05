module Company
  class CompanyEventsController < ApplicationController
    before_action :require_company_owner!

    def index
      @events = current_user.company.company_events
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
  end
end
