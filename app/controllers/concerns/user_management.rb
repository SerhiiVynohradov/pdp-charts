module UserManagement
  extend ActiveSupport::Concern

  included do
    include PdpChartsHelper

    before_action :set_user, only: [:show, :edit, :update, :destroy, :pause, :generate_meeting, :external_calendar, :make_manager]
  end

  def index
    @chart_data = chart_data
    @chart_label = chart_label
    @events = set_events

    render 'shared/users/index', locals: { read_only_mode: read_only_mode }
  end

  def edit
    render 'shared/users/edit'
  end

  def create
    @user = @team.users.new(user_params)

    # Generate Random Password
    random_password = Devise.friendly_token.first(8)

    # Assign Random Password
    @user.password = random_password
    @user.password_confirmation = random_password

    if @user.save
      # Send email with random password
      UserMailer.with(user: @user, password: random_password).welcome_email.deliver_later

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
    else
      if @user.update(user_params)
        redirect_to request.referrer, notice: I18n.t('messages.user.updated_successfully')
      else
        redirect_to request.referrer, alert: I18n.t('messages.user.update_failed')
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

  def make_manager
    if @user.team.present?
      team = @user.team

      old_managers = team.users.where(role: :manager)
      # Demote all old managers to :user
      old_managers.each do |old_manager|
        old_manager.update(role: :user)
        UserMailer.with(user: old_manager, team: team).manager_demoted_email.deliver_later
      end

      # Promote the new user
      @user.update(role: :manager)
      UserMailer.with(user: @user, team: team).manager_promoted_email.deliver_later
    end

    redirect_to request.referer || root_path
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
  def read_only_mode
    false
  end

  def chart_data
    labels_and_items = {}

    @team.users.map do |u|
      build_pdp_charts_data(u.items, label: u.name)

      labels_and_items[u.name] = u.items
    end

    data = build_pdp_charts_data_for_sets(labels_and_items)

    # 4) Добавляем три «нормативных» линии:
    #    - Бернаут (только на графике Effort)
    #    - Изменение приоритетов (только на графике WA)
    #    - Распыление (только на графике Items)
    data << build_pdp_constant_line_data(
      @team&.effort_line || 1000,
      label: 'Лінія ризику вигоряння',
      chart_type: :effort
    )
    data << build_pdp_constant_line_data(
      @team&.wa_line || 40,
      label: 'Лінія зміни пріорітетів',
      chart_type: :wa
    )
    data << build_pdp_constant_line_data(
      @team&.items_line || 5,
      label: 'Лінія розпилення',
      chart_type: :items
    )

    data
  end

  def chart_label
    I18n.t('labels.pdp_chart.for_team', team: @team.name)
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :role
    )
  end

  def set_user
    @user = @team.users.find(params[:id])
  end
end
