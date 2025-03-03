module Superadmin
  module Companies
    module Teams
      module Users
        class RecommendedItemsController < Superadmin::Companies::Teams::Users::BaseController
          include RecommendedItemsFetching
        end
      end
    end
  end
end
