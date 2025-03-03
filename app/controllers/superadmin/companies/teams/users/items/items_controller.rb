module Superadmin
  module Companies
    module Teams
      module Users
        module Items
          class ItemsController < Superadmin::Companies::Teams::Users::BaseController
            include ItemManagement
          end
        end
      end
    end
  end
end
