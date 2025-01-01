module My
  class ItemsController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource through: :current_user, class: "Item"

    def index
      @items = current_user.items
    end

    def create
      @item = current_user.items.build(item_params)
      if @item.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to my_items_path, notice: "Item created" }
        end
      else
        # Re-render the form in turbo_stream or HTML
        respond_to do |format|
          format.turbo_stream { render :new, status: :unprocessable_entity }
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
      @item = current_user.items.find(params[:id])
    end

    def update
      @item = current_user.items.find(params[:id])
      if @item.update(item_params)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to my_items_path, notice: "Item updated" }
        end
      else
        respond_to do |format|
          format.turbo_stream { render :edit, status: :unprocessable_entity }
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @item = current_user.items.find(params[:id])
      @item.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to my_items_path, notice: "Item deleted" }
      end
    end

    private

    def item_params
      # Add whichever fields you need
      params.require(:item).permit(:name, :category, :progress, :position)
    end
  end
end
