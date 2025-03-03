module Superadmin
  module Companies
    module Teams
      module Events
        class EventsController < Superadmin::Companies::Teams::BaseController
          include EventManagement

          private
          def object
            @team
          end
        end
      end
    end
  end
end
