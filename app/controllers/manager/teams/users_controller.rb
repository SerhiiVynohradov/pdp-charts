module Manager
  module Teams
    class UsersController < ApplicationController
      before_action :require_manager!
      before_action :set_team
      before_action :set_user, only: [:edit, :update, :destroy, :pause, :generate_meeting, :external_calendar]

      def index
        @users = @team.users
      end

      def new
        @user = @team.users.new
      end

      def create
        @user = @team.users.new(user_params)
        if @user.save
          respond_to do |format|
            format.html { redirect_to manager_team_path(@team), notice: "User added successfully." }
            format.turbo_stream
          end
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @user.update(user_params)
          respond_to do |format|
            format.html { redirect_to manager_team_path(@team), notice: "User updated successfully." }
            format.turbo_stream
          end
        else
          render :edit
        end
      end

      def destroy
        @user.destroy
        respond_to do |format|
          format.html { redirect_to manager_team_path(@team), notice: "User removed successfully." }
          format.turbo_stream
        end
      end

      def pause
        @user.update(paused: !@user.paused)
        respond_to do |format|
          format.html { redirect_to manager_team_path(@team), notice: "User status updated." }
          format.turbo_stream
        end
      end

      def generate_meeting
        # Implement Google Meet link generation logic here
        @meeting_link = "https://meet.google.com/xyz-abc-def" # Example link
        # Possibly store the link or send it via email
        redirect_to manager_team_user_path(@team, @user), notice: "Meeting link generated: #{@meeting_link}"
      end

      def external_calendar
        # Implement external calendar integration here
        @calendar_link = "https://calendar.google.com/calendar/event?..." # Example link
        redirect_to manager_team_user_path(@team, @user), notice: "External calendar link generated: #{@calendar_link}"
      end

      private

      def require_manager!
        redirect_to root_path, alert: "Access denied." unless current_user&.manager?
      end

      def set_team
        @team = current_user.managed_teams.find(params[:team_id])
      end

      def set_user
        @user = @team.users.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:name, :email, :role)
      end
    end
  end
end
