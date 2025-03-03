module CompanyOwner
  module Companies
    module Teams
      module Users
        class ItemProgressColumnsController < CompanyOwner::Companies::Teams::Users::BaseController
          include ItemProgressColumnManagement
        end
      end
    end
  end
end
