module My
  module Items
    class BaseController < My::BaseController
      before_action :set_item_context!

      private
      def set_item_context!
        @item = @user.items.find(params[:item_id])
        redirect_to root_path unless can?(:manage, @item)
      end
    end
  end
end
