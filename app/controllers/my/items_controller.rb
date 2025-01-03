module My
  class ItemsController < ApplicationController
    before_action :authenticate_user!

    def index
      @items = current_user.items.order(created_at: :desc)
    end

    def create
      @item = current_user.items.build(item_params)
      if @item.save
        respond_to do |format|
          format.turbo_stream # => create.turbo_stream.erb
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
      @item = current_user.items.find(params[:id])

      # If our Stimulus mini-form sends an Accept: application/json header,
      # we’ll respond with JSON. Otherwise, fallback to normal HTML.
      if request.format.json?
        # This is the partial cell edit
        if @item.update(item_params)
          # Return just the updated fields as JSON
          render json: @item.slice(
            :id,
            :name,
            :description,
            :link,
            :reason,
            :expected_results,
            :category,
            :progress,
            :effort,
            :result,
            :certificate_link
          ), status: :ok
        else
          render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
        end
      else
        # Normal HTML fallback
        if @item.update(item_params)
          redirect_to my_items_path, notice: "Item updated."
        else
          render :edit, status: :unprocessable_entity
        end
      end
    end

    def chart
      @item = current_user.items.find(params[:id])
      @chart_data = @item.progress_updates
    end

    private

    def item_params
      # All the columns you want to allow
      params.require(:item).permit(
        :name,
        :description,
        :link,
        :reason,
        :expected_results,
        :category,
        :progress,        # integer
        :effort,          # string
        :result,
        :certificate_link
      )
    end
  end
end
