module CompanyOwner
  module Companies
    module Teams
      module Events
        class EventsController < CompanyOwner::Companies::Teams::BaseController
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
