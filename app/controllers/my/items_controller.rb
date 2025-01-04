module My
  class ItemsController < ApplicationController
    include PdpChartsHelper

    before_action :authenticate_user!

    def index
      @items = current_user.items.order(created_at: :desc)
      @chart_data = [build_pdp_charts_data(@items, label: "My Items")]
      @chart_label = "My PDP Chart"

      # @chart_data = @items.map do |i|
      #   build_pdp_charts_data([i], label: i.name)
      # end
      # @chart_label = "Multiple PDP Charts"

      @new_item_form_url = my_items_path

      respond_to do |format|
        format.html { render 'shared/items/index' }
      end
    end

    def create
      @item = current_user.items.build(item_params)

      @new_item_form_url = my_items_path # for new form
      if @item.save
        respond_to do |format|
          format.turbo_stream { render partial: "shared/items/create", locals: { item: @item }, formats: [:turbo_stream] }
          format.html { redirect_to my_items_path, notice: "Item created." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render :new, status: :unprocessable_entity }
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @item = current_user.items.find(params[:id])
      respond_to do |format|
        format.turbo_stream { render partial: "shared/items/destroy", locals: { item: @item }, formats: [:turbo_stream] }
        format.html { redirect_to my_items_path, notice: "Item deleted." }
      end
      @item.destroy
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

    def show
      @item = current_user.items.find(params[:id])
      @chart_data = [build_pdp_charts_data([@item], label: @item.name)]
      @chart_label = "PDP Chart for #{@item.name}"

      render "shared/items/show", locals: { chart_data: @chart_data }
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
