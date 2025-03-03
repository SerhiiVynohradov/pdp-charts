module CompanyOwner
  module Companies
    module Events
      class EventsController < CompanyOwner::Companies::BaseController
        include EventManagement

        private
        def object
          @company
        end
      end
    end
  end
end
