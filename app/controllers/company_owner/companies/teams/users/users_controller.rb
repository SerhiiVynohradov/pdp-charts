# app/controllers/manager/teams/users_controller.rb

module Company
  module Teams
    module Users
      class UsersController < ApplicationController
        before_action :require_manager!
        before_action :set_team
        before_action :set_user, only: [:show, :edit, :update, :destroy, :pause, :generate_meeting, :external_calendar]

        def index
          redirect_to manager_team_path(@team)
        end

        def new
          @user = @team.users.new
        end

        def create
          @user = @team.users.new(user_params)
          @user.password = 'password'
          @user.password_confirmation = 'password'

          if @user.save
            respond_to do |format|
              format.html { redirect_to manager_team_path(@team), notice: "User added successfully." }
              format.turbo_stream { render partial: "shared/users/create", locals: { user: @user, team: @team }, formats: [:turbo_stream] }
            end
          else
            render :new
          end
        end

        def show
          redirect_to manager_team_user_items_path(@team, @user)
        end

        def edit
        end

        def update
          if request.format.json?
            # This is the partial cell edit
            if @user.update(user_params)
              # Return just the updated fields as JSON
              render json: @user.slice(
                :id,
                :name,
                :email
              ), status: :ok
            else
              render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
            end
          else
            # Normal HTML fallback
            if @user.update(user_params)
              redirect_to manager_team_path(@team), notice: "Item updated."
            else
              render :edit, status: :unprocessable_entity
            end
          end
        end

        def destroy
          respond_to do |format|
            format.html { redirect_to manager_team_path(@team), notice: "User removed successfully." }
            format.turbo_stream { render partial: "shared/users/destroy", locals: { user: @user, team: @team }, formats: [:turbo_stream] }
          end
          @user.destroy
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
          redirect_to root_path unless user_signed_in? && current_user.manager?
        end

        def set_team
          @team = current_user.owned_teams.find(params[:team_id])
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
end
