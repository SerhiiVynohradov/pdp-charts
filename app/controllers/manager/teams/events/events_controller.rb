module Manager
  module Teams
    module Events
      class EventsController < Manager::Teams::BaseController
        include EventManagement

        private
        def object
          @team
        end
      end
    end
  end
end
