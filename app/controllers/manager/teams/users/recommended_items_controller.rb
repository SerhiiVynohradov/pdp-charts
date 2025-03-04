module Manager
  module Teams
    module Users
      class RecommendedItemsController < Manager::Teams::Users::BaseController
        include RecommendedItemsFetching
      end
    end
  end
end
