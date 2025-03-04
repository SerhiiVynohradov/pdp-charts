module My
  module Teams
    module Events
      class EventsController < My::Teams::BaseController
        include EventManagement

        private
        def object
          @team
        end
      end
    end
  end
end
