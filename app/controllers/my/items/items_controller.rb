module My
  module Items
    class ItemsController < My::BaseController
      include ItemManagement

      private
      def chart_label
        'My PDP Chart'
      end

      def chart_items_label_index
        'My Items'
      end
    end
  end
end
