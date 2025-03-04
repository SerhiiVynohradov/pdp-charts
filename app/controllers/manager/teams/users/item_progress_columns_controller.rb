module Manager
  module Teams
    module Users
      class ItemProgressColumnsController < Manager::Teams::Users::BaseController
        include ItemProgressColumnManagement
      end
    end
  end
end
