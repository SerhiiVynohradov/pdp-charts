module Superadmin
  module Companies
    module Teams
      module Users
        class ItemProgressColumnsController < Superadmin::Companies::Teams::Users::BaseController
          include ItemProgressColumnManagement
        end
      end
    end
  end
end
