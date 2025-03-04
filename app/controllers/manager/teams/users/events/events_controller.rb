module Manager
  module Teams
    module Users
      module Events
        class EventsController < Manager::Teams::Users::BaseController
          include EventManagement

          private
          def object
            @user
          end
        end
      end
    end
  end
end
