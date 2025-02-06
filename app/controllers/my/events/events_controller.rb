module My
  module Events
    class EventsController < ApplicationController
      before_action :set_context

      include EventManagement

      private
      def set_context
        redirect_to root_path unless user_signed_in?
        @user = current_user
        redirect_to root_path unless can? :read, @user
      end

      def object
        @user
      end
    end
  end
end
