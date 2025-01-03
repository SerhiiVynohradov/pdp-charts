module Superadmin
  class CompaniesController < ApplicationController
    before_action :require_superadmin!

    def index
      @companies = Company.all
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

    def settings
      # ...
    end
  end
end
