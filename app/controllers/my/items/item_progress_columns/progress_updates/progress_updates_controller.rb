module My
  module Items
    module ItemProgressColumns
      module ProgressUpdates
        class ProgressUpdatesController < My::BaseController
          include ProgressUpdateManagement
        end
      end
    end
  end
end
