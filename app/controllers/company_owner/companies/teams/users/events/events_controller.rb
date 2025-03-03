module CompanyOwner
  module Companies
    module Teams
      module Users
        module Events
          class EventsController < CompanyOwner::Companies::Teams::Users::BaseController
            include EventManagement

            private
            def object
              @user
            end
          end
        end
      end
    end
  end
end
