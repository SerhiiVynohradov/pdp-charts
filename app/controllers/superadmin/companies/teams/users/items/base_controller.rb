module Superadmin
  module Companies
    module Teams
      module Users
        module Items
          class BaseController < Superadmin::Companies::Teams::Users::BaseController
            before_action :set_item_context!

            private
            def set_item_context!
              @item = @user.items.find(params[:item_id])
              redirect_to root_path unless can?(:manage, @item)
            end
          end
        end
      end
    end
  end
end
