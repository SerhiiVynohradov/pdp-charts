module Manager
  module Teams
    class RecommendedItemsController < Manager::Teams::BaseController
      include RecommendedItemsManagement
    end
  end
end
