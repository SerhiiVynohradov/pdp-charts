module ItemProgressColumnManagement
  extend ActiveSupport::Concern

  included do
    before_action :set_item_progress_column, only: [:edit_item_progress_column, :update_item_progress_column, :destroy_item_progress_column]
    before_action :authorize_manage_progress_columns!
  end

  def new_item_progress_column
    @item_progress_column = @user.item_progress_columns.new
    respond_to do |format|
      format.turbo_stream
      format.html { render partial: "shared/item_progress_columns/form", locals: { item_progress_column: @item_progress_column }, layout: false }
    end
  end

  def create_item_progress_column
    @item_progress_column = @user.item_progress_columns.build(item_progress_column_params)
    if @item_progress_column.save
      respond_to do |format|
        format.turbo_stream { render partial: "shared/item_progress_columns/create", locals: { item_progress_column: @item_progress_column }, formats: [:turbo_stream] }
        format.html { redirect_to the_item_path(@item_progress_column.items.first), notice: "Progress column successfully created." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render partial: "shared/item_progress_columns/form", locals: { item_progress_column: @item_progress_column }, formats: [:turbo_stream] }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit_item_progress_column
    respond_to do |format|
      format.turbo_stream
      format.html { render partial: "shared/item_progress_columns/form", locals: { item_progress_column: @item_progress_column }, layout: false }
    end
  end

  def update_item_progress_column
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

  def destroy_item_progress_column
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
