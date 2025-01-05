module TeamManagement
  extend ActiveSupport::Concern

  included do
    include PdpChartsHelper
  end

  def index
    @chart_data = chart_data
    @chart_label = chart_label

    render 'shared/teams/index'
  end

  def create
    @team = @company.teams.build(team_params)

    if @team.save
      respond_to do |format|
        format.turbo_stream { render partial: "shared/teams/create", locals: { team: @team }, formats: [:turbo_stream] }
        format.html { redirect_to my_items_path, notice: "Item created." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    # ...
  end

  def destroy
    respond_to do |format|
      format.turbo_stream { render partial: "shared/teams/destroy", locals: { team: @team }, formats: [:turbo_stream] }
      format.html { redirect_to my_items_path, notice: "Item deleted." }
    end
    @team.destroy
  end

  # def details
  #   # open manager-like view but from company perspective
  # end

  # def settings
  #   # ...
  # end

  # def recommended
  #   # ...
  # end

  # def charts
  #   @team = current_user.managed_teams.find(params[:id])
  #   # build multi-line chart for each user in the team
  # end

  # def settings
  #   @team = current_user.managed_teams.find(params[:id])
  # end

  # def recommended
  #   @team = current_user.managed_teams.find(params[:id])
  #   # recommended items CRUD
  # end

  def team_params
    params.require(:team).permit(
      :name
    )
  end

  def chart_data
    @chart_data = @teams.map do |t|
      team_users = t.users
      team_items = Item.where(user: team_users)

      build_pdp_charts_data(team_items, label: t.name)
    end
  end

  def chart_label
    @chart_label = "PDP Chart for company #{@company.name}"
  end
end
