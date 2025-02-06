module EventManagement
  extend ActiveSupport::Concern

  included do
    before_action :set_events, only: [:index]

    before_action :set_event, only: [:update, :destroy]
    before_action :authorize_manage_event!, only: [:update, :destroy]
  end

  def index
    render 'shared/events/index', locals: { read_only_mode: read_only_mode }
  end

  def create
    if defined?(object) && object.present?
      @event = object.events.build(event_params)
    else
      @event = Event.new(event_params)
    end

    if @event.save
      respond_to do |format|
        format.turbo_stream { render partial: "shared/events/create", locals: { event: @event }, formats: [:turbo_stream] }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if request.format.json?
      if @event.update(event_params)
        render json: @event.slice(
          :id,
          :name,
          :date,
        ), status: :ok
      else
        render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    respond_to do |format|
      format.turbo_stream { render partial: "shared/events/destroy", locals: { event: @event }, formats: [:turbo_stream] }
    end
    @event.destroy
  end

  private
  def read_only_mode
    false
  end

  def event_params
    params.require(:event).permit(
      :name,
      :date,
    )
  end

  def set_event
    if defined?(object) && object.present?
      @event = object.events.find(params[:id])
    else
      @event = Event.find(params[:id])
    end
  end

  def set_events
    if defined?(object) && object.present?
      @events = object.events
    else
      @events = Event.all
    end
  end

  def authorize_manage_event!
    redirect_to root_path unless @event.present? && (can? :manage, @event)
  end
end
