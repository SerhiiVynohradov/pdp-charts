module CompanyOwner
  module Companies
    class RecommendedItemsController < CompanyOwner::Companies::BaseController
      include RecommendedItemsManagement
    end
  end
end
