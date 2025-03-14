module CompanyManagement
  extend ActiveSupport::Concern

  included do
    include PdpChartsHelper

    before_action :set_companies, only: [:index]

    before_action :set_company, only: [:show, :edit, :update, :destroy]
    before_action :authorize_manage_company!, only: [:show, :edit, :update, :destroy]
  end

  def index
    @chart_data = chart_data_index
    @chart_label = chart_label_index
    @events = set_events

    render 'shared/companies/index', locals: { read_only_mode: read_only_mode }
  end

  def show
    @chart_data = chart_data_show
    @chart_label = chart_label_show
    @events = set_events

    render 'shared/companies/show'
  end

  def edit
    render 'shared/companies/edit'
  end

  def create
    @company = Company.build(company_params)

    if @company.save
      respond_to do |format|
        format.turbo_stream { render partial: "shared/companies/create", locals: { company: @company }, formats: [:turbo_stream] }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if request.format.json?
      if @company.update(company_params)
        render json: @company.slice(
          :id,
          :name
        ), status: :ok
      else
        render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
      end

    else
      if @company.update(company_params)
        redirect_to request.referrer, notice: I18n.t('messages.company.updated_successfully')
      else
        redirect_to request.referrer, alert: I18n.t('messages.company.update_failed')
      end
    end
  end

  def destroy
    respond_to do |format|
      format.turbo_stream { render partial: "shared/companies/destroy", locals: { company: @company }, formats: [:turbo_stream] }
    end
    @company.destroy
  end

  private
  def read_only_mode
    false
  end

  def company_params
    params.require(:company).permit(
      :name,
      :charts_visible
    )
  end

  def chart_data_index
    labels_and_items = {}

    @companies.each do |c|
      teams = c.teams
      users = User.where(team: teams)
      items = Item.where(user: users)

      labels_and_items[c.name] = items
    end

    data = build_pdp_charts_data_for_sets(labels_and_items)
  end

  def chart_data_show
    @company.teams.map do |t|
      team_users = User.where(team: t.users)
      team_items = Item.where(user: team_users)

      build_pdp_charts_data(team_items, label: t.name)
    end
  end

  def chart_label_index
    I18n.t('labels.pdp_chart.for_all_companies')
  end

  def chart_label_show
    I18n.t('labels.pdp_chart.for_company', company: @company.name)
  end

  def set_company
    @company = Company.find(params[:id])
  end

  def set_companies
    @companies = Company.all
  end

  def authorize_manage_company!
    redirect_to root_path unless @company.present? && (can? :manage, @company)
  end
end
