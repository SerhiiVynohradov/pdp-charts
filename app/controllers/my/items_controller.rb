module My
  class ItemsController < ApplicationController
    before_action :authenticate_user!

    def index
      @items = current_user.items.order(created_at: :desc)
      @chart_data = build_pdp_charts_data(@items)
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

    # Produces the arrays for #Items, Weighted Average, and PDP Effort
    def build_pdp_charts_data(items)
      # Let’s define 4 quarters in 2024 (Q1..Q4).
      # You can adapt for any real logic or multiple years.
      quarters = [
        { name: "Q1 2024", start: Date.new(2024,1,1),  end: Date.new(2024,3,31) },
        { name: "Q2 2024", start: Date.new(2024,4,1),  end: Date.new(2024,6,30) },
        { name: "Q3 2024", start: Date.new(2024,7,1),  end: Date.new(2024,9,30) },
        { name: "Q4 2024", start: Date.new(2024,10,1), end: Date.new(2024,12,31) }
      ]

      itemsData  = []
      waData     = []
      effortData = []

      quarters.each_with_index do |q, idx|
        items_count                  = 0
        sum_of_diff_times_effort     = 0.0
        sum_of_effort_for_active     = 0.0

        items.each do |item|
          current_progress = item.quarter_progress(q[:start], q[:end]) || 0

          prev_progress = if idx == 0
            0 # No previous quarter for Q1
          else
            prev_q = quarters[idx - 1]
            item.quarter_progress(prev_q[:start], prev_q[:end]) || 0
          end

          diff = current_progress - prev_progress
          if diff > 0
            # If there's an actual increase, we count the item
            items_count += 1

            w = item.effort.to_f  # the weight
            sum_of_diff_times_effort += (diff * w)
            sum_of_effort_for_active  += w
          end
        end

        wa  = 0.0
        if sum_of_effort_for_active > 0
          wa = sum_of_diff_times_effort / sum_of_effort_for_active
        end

        pdp_eff = wa * sum_of_effort_for_active

        # We'll pick the start of the quarter as the x-value
        x_date = q[:start]

        itemsData  << { x: x_date, y: items_count }
        waData     << { x: x_date, y: wa.round(2) }
        effortData << { x: x_date, y: pdp_eff.round(2) }
      end

      {
        items_data:  itemsData,
        wa_data:     waData,
        effort_data: effortData
      }
    end

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
