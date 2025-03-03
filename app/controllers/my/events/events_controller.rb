module My
  module Events
    class EventsController < My::BaseController
      include EventManagement

      private

      def object
        @user
      end
    end
  end
end
