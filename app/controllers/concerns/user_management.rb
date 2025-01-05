module UserManagement
  extend ActiveSupport::Concern

  included do
    include PdpChartsHelper

    before_action :set_team
    before_action :authorize_manage_team!

    before_action :set_user, only: [:show, :update, :destroy, :pause, :generate_meeting, :external_calendar]
  end

  def index
    @chart_data = chart_data
    @chart_label = chart_label

    render 'shared/users/index'
  end

  def create
    @user = @team.users.new(user_params)
    @user.password = 'password'
    @user.password_confirmation = 'password'

    if @user.save
      respond_to do |format|
        format.turbo_stream { render partial: "shared/users/create", locals: { user: @user, team: @team }, formats: [:turbo_stream] }
      end
    end
  end

  def update
    if request.format.json?
      if @user.update(user_params)
        render json: @user.slice(
          :id,
          :name,
          :email
        ), status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    respond_to do |format|
      format.turbo_stream { render partial: "shared/users/destroy", locals: { user: @user }, formats: [:turbo_stream] }
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

  def chart_data
    @team.users.map do |u|
      build_pdp_charts_data(u.items, label: u.name)
    end
  end

  def chart_label
    "PDP Chart for team #{@team.name}"
  end

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end

  def authorize_manage_team!
    redirect_to root_path unless @team.present? && (can? :manage, @team)
  end

  def set_user
    @user = @team.users.find(params[:id])
  end
end
