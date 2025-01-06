module My
  module Items
    class ItemsController < ApplicationController
      before_action :authenticate_user!

      include ItemManagement

      private
      def chart_label
        'My PDP Chart'
      end

      def chart_items_label_index
        'My Items'
      end

      def set_user
        @user = current_user
      end
    end
  end
end
