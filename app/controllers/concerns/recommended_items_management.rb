module RecommendedItemsManagement
  extend ActiveSupport::Concern

  included do
    # todo: before_action :authorize_manage_user!
    # todo: reject to root if I'm just a user (neither manager nor company owner nor superadmin)

    before_action :set_recommended_items, only: [:index]
    before_action :set_recommended_item, only: [:show, :update, :destroy]
  end

  def index
    render 'shared/recommended_items/index'
  end

  def show
    render 'shared/recommended_items/show'
  end

  def create
    @recommended_item = RecommendedItem.build(recommended_item_params)

    if current_user.manager?
      @recommended_item.team_id = current_user.team_id
    elsif current_user.company_owner?
      @recommended_item.company_id = current_user.company_id
    end

    if @recommended_item.save
      respond_to do |format|
        format.turbo_stream { render partial: "shared/recommended_items/create", locals: { recommended_item: @recommended_item }, formats: [:turbo_stream] }
      end
    end
  end

  def update
    if request.format.json?
      if @recommended_item.update(recommended_item_params)
        data = @recommended_item.slice(
          :id,
          :name,
          :description,
          :link,
          :expected_results,
          :effort
        )

        data[:category_id] = @recommended_item.category&.name

        render json: data, status: :ok
      else
        render json: { errors: @recommended_item.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    respond_to do |format|
      format.turbo_stream { render partial: "shared/recommended_items/destroy", locals: { recommended_item: @recommended_item }, formats: [:turbo_stream] }
    end
    @recommended_item.destroy
  end

  private
  def recommended_item_params
    params.require(:recommended_item).permit(
      :name,
      :description,
      :link,
      :expected_results,
      :category_id,
      :effort
    )
  end

  def set_recommended_items
    if current_user.manager?
      @recommended_items = RecommendedItem.where(team_id: current_user.team_id).order(created_at: :desc)
    elsif current_user.company_owner?
      @recommended_items = RecommendedItem.where(company_id: current_user.company_id).order(created_at: :desc)
    elsif current_user.superadmin?
      @recommended_items = RecommendedItem.where(company_id: nil, team_id: nil).order(created_at: :desc)
    end
  end

  def set_recommended_item
    if current_user.manager?
      @recommended_item = RecommendedItem.where(team_id: current_user.team_id).find(params[:id])
    elsif current_user.company_owner?
      @recommended_item = RecommendedItem.where(company_id: current_user.company_id).find(params[:id])
    elsif current_user.superadmin?
      @recommended_item = RecommendedItem.where(company_id: nil, team_id: nil).find(params[:id])
    end
  end
end
