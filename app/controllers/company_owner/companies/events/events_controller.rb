module CompanyOwner
  module Companies
    module Events
      class EventsController < ApplicationController
        before_action :set_context

        include EventManagement

        private
        def set_context
          redirect_to root_path unless current_user&.company_owner?
          @company = Company.find(params[:company_id])
          redirect_to root_path unless can? :read, @company
        end

        def object
          @company
        end
      end
    end
  end
end
