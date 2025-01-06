module ProgressUpdateManagement
  extend ActiveSupport::Concern

  included do
    before_action :set_progress_update, only: [:update_progress_update, :destroy_progress_update]
    before_action :authorize_manage_progress_updates!
  end

  def create_progress_update
    @item_progress_column = @user.item_progress_columns.find(params[:item_progress_column_id])
    @progress_update = @item.progress_updates.find_or_initialize_by(item_progress_column: @item_progress_column)
    @progress_update.percent = progress_update_params[:percent]

    if @progress_update.save
      respond_to do |format|
        format.turbo_stream { render partial: "shared/progress_updates/update", locals: { progress_update: @progress_update }, formats: [:turbo_stream] }
        format.html { redirect_to the_item_path(@item_progress_column.items.first), notice: "Progress update successfully saved." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render partial: "shared/progress_updates/form", locals: { progress_update: @progress_update }, formats: [:turbo_stream] }
        format.html { render :show, status: :unprocessable_entity }
      end
    end
  end

  def update_progress_update
    if @progress_update.update(progress_update_params)
      respond_to do |format|
        format.turbo_stream { render partial: "shared/progress_updates/update", locals: { progress_update: @progress_update }, formats: [:turbo_stream] }
        format.json { render json: @progress_update, status: :ok }
        format.html { redirect_to the_item_path(@progress_update.item), notice: "Progress update successfully updated." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render partial: "shared/progress_updates/form", locals: { progress_update: @progress_update }, formats: [:turbo_stream] }
        format.json { render json: { errors: @progress_update.errors.full_messages }, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy_progress_update
    @progress_update.destroy
    respond_to do |format|
      format.turbo_stream { render partial: "shared/progress_updates/destroy", locals: { progress_update: @progress_update }, formats: [:turbo_stream] }
      format.html { redirect_to the_item_path(@progress_update.item), notice: "Progress update successfully deleted." }
    end
  end

  private

  def set_progress_update
    @progress_update = ProgressUpdate.find(params[:id])
  end

  def progress_update_params
    params.require(:progress_update).permit(:percent)
  end

  def authorize_manage_progress_updates!
    redirect_to root_path unless can?(:manage, @user)
  end
end
