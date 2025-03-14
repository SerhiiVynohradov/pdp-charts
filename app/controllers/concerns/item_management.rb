module ItemManagement
  extend ActiveSupport::Concern

  included do
    include PdpChartsHelper

    before_action :set_items, only: [:index]
    before_action :set_item, only: [:show, :update, :destroy, :recommend]
    before_action :set_data
  end

  def index
    @chart_data = chart_data_index
    @chart_label = chart_label_index
    @events = set_events

    render 'shared/items/index', locals: { read_only_mode: read_only_mode }
  end

  def show
    @chart_data = chart_data_show
    @chart_label = chart_label_show
    @events = set_events

    render 'shared/items/show'
  end

  def pause
  end

  def recommend
    # Шаг 1. Собираем поля из @item (копируем в RecommendedItem)
    recommended_item = RecommendedItem.new(
      name:             @item.name,
      description:      @item.description,
      link:             @item.link,
      expected_results: @item.expected_results,
      effort:           @item.effort,
      category_id:      @item.category_id
    )

    # Шаг 2. Определяем, на каком уровне делаем рекомендацию
    # (суперадмин → глобальный, оунер → company_id, менеджер → team_id)
    if @superadmin
      # Глобальный уровень
      recommended_item.team_id = nil
      recommended_item.company_id = nil
    elsif @company.present?
      # Для оунера
      recommended_item.company_id = @company.id
      recommended_item.team_id = nil  # Обычно
    elsif @team.present?
      # Для менеджера
      recommended_item.team_id = @team.id
    else
      # Если это обычный пользователь (my) — возможно, ничего не делаем
      flash[:alert] = "You have no permission to recommend this item."
      return redirect_to request.referer || root_path
    end

    # Шаг 3. Сохраняем RecommendedItem
    if recommended_item.save
      flash[:notice] = I18n.t('messages.item.recommended_successfully')
    else
      flash[:alert] = "Failed to recommend: #{recommended_item.errors.full_messages.join(', ')}"
    end

    # Шаг 4. Редирект обратно (или куда нужно)
    redirect_to request.referer || root_path
  end

  def create
    @item = @user.items.build(item_params)

    if params[:item][:recommended_item_id].present?
      recommended_item = RecommendedItem.find(params[:item][:recommended_item_id])
      @item.name = recommended_item.name
      @item.description = recommended_item.description
      @item.link = recommended_item.link
      @item.expected_results = recommended_item.expected_results
      @item.effort = recommended_item.effort if @item.effort.blank?
      @item.category_id = recommended_item.category_id if @item.category_id.blank?
    end

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
        data[:effort] = case @item.effort.to_s
                        when "5"
                          I18n.t('effort.very_hard')
                        when "4"
                          I18n.t('effort.hard')
                        when "3"
                          I18n.t('effort.medium')
                        when "2"
                          I18n.t('effort.easy')
                        when "1"
                          I18n.t('effort.very_easy')
                        else
                          "-"
                        end

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

  def chart_data_index
    labels_and_items = {}

    labels_and_items['All'] = @items

    no_cat_items = @items.where(category_id: nil)
    labels_and_items['No Category'] = no_cat_items if no_cat_items.exists?

    category_ids = @items.where.not(category_id: nil).pluck(:category_id).uniq
    Category.where(id: category_ids).each do |category|
      labels_and_items[category.name] = @items.where(category: category)
    end

    data = build_pdp_charts_data_for_sets(labels_and_items)

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

  def chart_data_show
    [ build_pdp_charts_data([@item], label: @item.name) ]
  end

  def chart_label_index
    I18n.t('labels.pdp_chart.for_user', user: @user.name)
  end

  def chart_label_show
    I18n.t('labels.pdp_chart.for_item', item: @item.name)
  end

  def set_data
    @progress_columns = @user.item_progress_columns.order(date: :asc)
    @categories = Category.all
  end

  def set_items
    @items = @user.items
                 .order(created_at: :desc)
                 .includes(:category, progress_updates: :item_progress_column)
  end

  def set_item
    @item = @user.items.find(params[:id])
  end

  def read_only_mode
    false
  end
end
