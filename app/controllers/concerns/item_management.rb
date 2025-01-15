module ItemManagement
  extend ActiveSupport::Concern

  included do
    include PdpChartsHelper

    before_action :set_user
    # todo: before_action :authorize_manage_user!

    before_action :set_items, only: [:index]
    before_action :set_item, only: [:show, :update, :destroy]
  end

  def index
    @chart_data = chart_data_index
    @chart_label = chart_label_index

    render 'shared/items/index'
  end

  def show
    @chart_data = chart_data_show
    @chart_label = chart_label_show

    render 'shared/items/show'
  end

  def pause
  end

  def create
    @item = @user.items.build(item_params)

    if @item.save
      respond_to do |format|
        format.turbo_stream { render partial: "shared/items/create", locals: { item: @item }, formats: [:turbo_stream] }
      end
    end
  end

  def update
    if request.format.json?
      if @item.update(item_params)
        data = @item.slice(
          :id,
          :name,
          :description,
          :link,
          :reason,
          :expected_results,
          :progress,
          :effort,
          :result,
          :certificate_link
        )

        data[:category_id] = @item.category&.name

        render json: data, status: :ok
      else
        render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    respond_to do |format|
      format.turbo_stream { render partial: "shared/items/destroy", locals: { item: @item }, formats: [:turbo_stream] }
    end
    @item.destroy
  end

  private
  def item_params
    params.require(:item).permit(
      :name,
      :description,
      :link,
      :reason,
      :expected_results,
      :category,
      :category_id,
      :progress,        # integer
      :effort,          # string
      :result,
      :certificate_link
    )
  end

  def set_items
    @items = @user.items.order(created_at: :desc)
  end

  def set_item
    @item = @user.items.find(params[:id])
  end

  def chart_data_index
    [build_pdp_charts_data(@items, label: chart_items_label_index)]
  end

  def chart_items_label_index
    "PDP Items of #{@user.name}"
  end

  def chart_label_index
    "PDP Chart for #{@user.name}"
  end

  def chart_data_show
    [build_pdp_charts_data([@item], label: @item.name)]
  end

  def chart_label_show
    "PDP Chart for #{@item.name}"
  end

  def set_user
    @user = @team.users.find(params[:user_id])
  end
end
