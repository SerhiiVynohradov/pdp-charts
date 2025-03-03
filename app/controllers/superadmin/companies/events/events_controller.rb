module Superadmin
  module Companies
    module Events
      class EventsController < Superadmin::Companies::BaseController
        include EventManagement

        private
        def object
          @company
        end
      end
    end
  end
end
