module My
  module Items
    module ItemProgressColumns
      module ProgressUpdates
        class ProgressUpdatesController < ApplicationController
          before_action :authenticate_user!

          include ProgressUpdateManagement

          private
          def set_user
            @user = current_user
          end
        end
      end
    end
  end
end
