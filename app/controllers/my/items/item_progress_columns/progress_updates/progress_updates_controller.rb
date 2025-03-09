module My
  module Items
    module ItemProgressColumns
      module ProgressUpdates
        class ProgressUpdatesController < My::Items::BaseController
          include ProgressUpdateManagement
        end
      end
    end
  end
end
