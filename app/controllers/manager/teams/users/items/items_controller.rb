module Manager
  module Teams
    module Users
      module Items
        class ItemsController < Manager::Teams::Users::BaseController
          include ItemManagement
        end
      end
    end
  end
end
