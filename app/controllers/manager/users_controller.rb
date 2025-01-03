module Manager
  class UsersController < ApplicationController
    before_action :require_superadmin!

    def index
      # ...
    end

    def create
      # ...
    end

    def update
      # ...
    end

    def destroy
      # ...
    end

    def pause
      # ...
    end
  end
end
