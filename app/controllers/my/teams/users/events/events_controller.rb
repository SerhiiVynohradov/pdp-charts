module My
  module Teams
    module Users
      module Events
        class EventsController < My::Teams::Users::BaseController
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
