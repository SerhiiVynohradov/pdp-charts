module CompanyOwner
  module Companies
    module Teams
      module Users
        class RecommendedItemsController < CompanyOwner::Companies::Teams::Users::BaseController
          include RecommendedItemsFetching
        end
      end
    end
  end
end
