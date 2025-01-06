module ItemProgressColumnManagement
  extend ActiveSupport::Concern

  included do
    before_action :set_user

    before_action :set_item_progress_column, only: [:edit, :update, :destroy]
    before_action :authorize_manage_progress_columns!
  end

  def new
    @item_progress_column = @user.item_progress_columns.new

    respond_to do |format|
      # Для Turbo Frame запросов
      format.html { render partial: "shared/item_progress_columns/new", locals: { item_progress_column: @item_progress_column } }
      # Для Turbo Stream (если понадобится)
      format.turbo_stream { render turbo_stream: turbo_stream.replace("add_progress_column", partial: "shared/item_progress_columns/form", locals: { item_progress_column: @item_progress_column }) }
    end
  end

  def create
    @item_progress_column = @user.item_progress_columns.build(item_progress_column_params)
    if @item_progress_column.save
      respond_to do |format|
        format.turbo_stream { render partial: "shared/item_progress_columns/create", locals: { item_progress_column: @item_progress_column }, formats: [:turbo_stream] }
        format.html { redirect_to the_item_path(@item_progress_column.items.first), notice: "Progress column successfully created." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render partial: "shared/item_progress_columns/create", locals: { item_progress_column: @item_progress_column }, formats: [:turbo_stream] }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream
      format.html { render partial: "shared/item_progress_columns/form", locals: { item_progress_column: @item_progress_column }, layout: false }
    end
  end

  def update
    if @item_progress_column.update(item_progress_column_params)
      respond_to do |format|
        format.turbo_stream { render partial: "shared/item_progress_columns/update", locals: { item_progress_column: @item_progress_column }, formats: [:turbo_stream] }
        format.html { redirect_to the_item_path(@item_progress_column.items.first), notice: "Progress column successfully updated." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render partial: "shared/item_progress_columns/form", locals: { item_progress_column: @item_progress_column }, formats: [:turbo_stream] }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @item_progress_column.destroy
    respond_to do |format|
      format.turbo_stream { render partial: "shared/item_progress_columns/destroy", locals: { item_progress_column: @item_progress_column }, formats: [:turbo_stream] }
      format.html { redirect_to the_item_path(@item_progress_column.items.first), notice: "Progress column successfully deleted." }
    end
  end

  private

  def set_item_progress_column
    @item_progress_column = @user.item_progress_columns.find(params[:id])
  end

  def item_progress_column_params
    params.require(:item_progress_column).permit(:date)
  end

  def authorize_manage_progress_columns!
    redirect_to root_path unless can?(:manage, @user)
  end
end
