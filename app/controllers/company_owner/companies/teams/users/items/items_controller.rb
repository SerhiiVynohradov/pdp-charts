module CompanyOwner
  module Companies
    module Teams
      module Users
        module Items
          class ItemsController < CompanyOwner::Companies::Teams::Users::BaseController
            include ItemManagement
          end
        end
      end
    end
  end
end
