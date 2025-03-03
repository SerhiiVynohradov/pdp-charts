module My
  class RecommendedItemsController < My::BaseController
    include RecommendedItemsFetching
  end
end
