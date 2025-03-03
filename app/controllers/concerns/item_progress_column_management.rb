module ItemProgressColumnManagement
  extend ActiveSupport::Concern

  included do
    before_action :set_item_progress_column, only: [:edit, :update, :destroy]
    before_action :authorize_manage_progress_columns!
    before_action :set_data
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
    if params[:item_progress_column][:full_year] == "1"
      year = params[:item_progress_column][:date].to_date.year  # Берём год из выбранной даты
      quarter_dates = [
        Date.new(year, 1, 10),
        Date.new(year, 4, 10),
        Date.new(year, 7, 10),
        Date.new(year, 11, 10)
      ]

      begin
        ActiveRecord::Base.transaction do
          quarter_dates.each do |d|
            @user.item_progress_columns.find_or_create_by(date: d)
          end
        end
        respond_successfully
      rescue ActiveRecord::RecordInvalid => e
        respond_with_errors(e.message)
      end

    else
      @item_progress_column = @user.item_progress_columns.find_or_create_by(item_progress_column_params)

      respond_successfully
      # todo: notify if it already exists
      # if @item_progress_column.save
      # else
      # respond_with_errors(@item_progress_column.errors.full_messages.join(", "))
      # end
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
        format.turbo_stream do
          # Рендерим паршиал update.turbo_stream.erb
          render partial: "shared/item_progress_columns/update",
                 locals: { item_progress_column: @item_progress_column },
                 formats: [:turbo_stream]
        end

        format.html do
          redirect_to some_path, notice: t('messages.progress_column.updated_successfully')
        end
      end
    else
      respond_to do |format|
        # Если ошибка — можно заново показать форму, но обычно проще inline...
        format.turbo_stream do
          render partial: "shared/item_progress_columns/form", # например
                 locals: { item_progress_column: @item_progress_column },
                 formats: [:turbo_stream],
                 status: :unprocessable_entity
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @item_progress_column.destroy

    respond_to do |format|
      format.turbo_stream do
        render partial: "shared/item_progress_columns/destroy",
               locals: { item_progress_column: @item_progress_column },
               formats: [:turbo_stream]
      end
      format.html do
        redirect_to some_path, notice: t('messages.progress_column.deleted_successfully')
      end
    end
  end

  private

  def item_progress_column_params
    params.require(:item_progress_column).permit(:date, :full_year)
  end

  def respond_successfully
    respond_to do |format|
      format.turbo_stream {
        render partial: "shared/item_progress_columns/create",
               locals: { item_progress_column: @item_progress_column }, # можно nil или последний
               formats: [:turbo_stream]
      }
      format.html {
        redirect_to some_path, notice: t('messages.progress_column.created_successfully')
      }
    end
  end

  def respond_with_errors(error_message)
    respond_to do |format|
      format.turbo_stream {
        render partial: "shared/item_progress_columns/form",
               locals: { item_progress_column: @item_progress_column },
               formats: [:turbo_stream],
               status: :unprocessable_entity
      }
      format.html {
        flash[:alert] = error_message
        render :new, status: :unprocessable_entity
      }
    end
  end

  def set_data
    @categories = Category.all
    @progress_columns = @user.item_progress_columns.order(date: :asc)
  end

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
