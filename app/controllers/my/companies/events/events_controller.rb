module My
  module Companies
    module Events
      class EventsController < My::Companies::BaseController
        include EventManagement

        private
        def object
          @company
        end
      end
    end
  end
end
