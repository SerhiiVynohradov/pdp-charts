module Superadmin
  module Events
    class EventsController < ApplicationController
      before_action :require_superadmin!
      before_action :set_superadmin

      include EventManagement

      def show
        # redirect_to superadmin_events_path(@company)
      end

      private
      def require_superadmin!
        redirect_to root_path unless current_user&.superadmin?
      end

      def set_superadmin
        # @superadmin = true - because the form uses it to create company events - for now skipping
      end
    end
  end
end
