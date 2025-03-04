module Manager
  module Teams
    module Users
      module Items
        module ItemProgressColumns
          module ProgressUpdates
            class ProgressUpdatesController < Manager::Teams::Users::BaseController
              include ProgressUpdateManagement
            end
          end
        end
      end
    end
  end
end
