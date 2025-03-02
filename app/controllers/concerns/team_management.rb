module TeamManagement
  extend ActiveSupport::Concern

  included do
    include PdpChartsHelper

    before_action :set_teams, only: [:index]

    before_action :set_team, only: [:show, :edit, :update, :destroy]
    before_action :authorize_manage_team!, only: [:show, :edit, :update, :destroy]
  end

  def index
    @chart_data = chart_data
    @chart_label = chart_label
    @events = set_events

    render 'shared/teams/index', locals: { read_only_mode: read_only_mode }
  end

  def edit
    render 'shared/teams/edit'
  end

  def create
    @team = @company.teams.build(team_params)

    if @team.save
      respond_to do |format|
        format.turbo_stream { render partial: "shared/teams/create", locals: { team: @team }, formats: [:turbo_stream] }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if request.format.json? # inline table
      if @team.update(team_params)
        render json: @team.slice(
          :id,
          :name
        ), status: :ok
      else
        render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
      end
    else # html form
      if @team.update(team_params)
        redirect_to request.referrer, notice: I18n.t('messages.team.updated_successfully')
      else
        redirect_to request.referrer, alert: I18n.t('messages.team.update_failed')
      end
    end
  end

  def destroy
    respond_to do |format|
      format.turbo_stream { render partial: "shared/teams/destroy", locals: { team: @team }, formats: [:turbo_stream] }
    end
    @team.destroy
  end

  private
  def read_only_mode
    false
  end

  def team_params
    params.require(:team).permit(
      :name,
      :charts_visible,
      # :status
      :effort_line,
      :wa_line,
      :items_line
    )
  end

  def chart_data
    labels_and_items = {}

    @teams.map do |t|
      team_users = t.users
      team_items = Item.where(user: team_users)

      labels_and_items[t.name] = team_items
    end

    data = build_pdp_charts_data_for_sets(labels_and_items)
  end

  def chart_label
    I18n.t('labels.pdp_chart.for_company', company: @company.name)
  end

  def set_team
    @team = @company.teams.find(params[:id])
  end

  def set_teams
    @teams = @company.teams
  end

  def authorize_manage_team!
    redirect_to root_path unless @team.present? && (can? :manage, @team)
  end
end
