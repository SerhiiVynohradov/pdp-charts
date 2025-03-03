module Superadmin
  module Companies
    module Teams
      module Users
        module Items
          module ItemProgressColumns
            module ProgressUpdates
              class ProgressUpdatesController < Superadmin::Companies::Teams::Users::Items::BaseController
                include ProgressUpdateManagement
              end
            end
          end
        end
      end
    end
  end
end
