module CompanyOwner
  module Companies
    module Teams
      module Users
        module Items
          module ItemProgressColumns
            module ProgressUpdates
              class ProgressUpdatesController < CompanyOwner::Companies::Teams::Users::BaseController
                include ProgressUpdateManagement
              end
            end
          end
        end
      end
    end
  end
end
