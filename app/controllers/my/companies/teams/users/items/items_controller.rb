module My
  module Companies
    module Teams
      module Users
        module Items
          class ItemsController < My::Companies::Teams::Users::BaseController
            before_action :set_items, only: :index
            before_action :set_item, only: :show
            before_action :set_data

            include PdpChartsHelper

            def index
              @chart_data = chart_data_index
              @chart_label = chart_label_index

              render 'shared/items/index', locals: { read_only_mode: true }
            end

            def show
              @chart_data = chart_data_show
              @chart_label = chart_label_show

              render 'shared/items/show'
            end

            private
            def set_data
              @progress_columns = @user.item_progress_columns.order(date: :asc)
              @categories = Category.all
            end

            def set_items
              @items = @user.items.order(created_at: :desc)
            end

            def set_item
              @item = @user.items.find(params[:id])
            end

            def chart_data_index
              data = []

              # 1) Все айтемы (одна линия)
              data << build_pdp_charts_data(@items, label: 'All')

              # 2) Айтемы без категории (одна линия)
              if @items.where(category_id: nil).any?
                data << build_pdp_charts_data(@items.where(category_id: nil), label: 'No Category')
              end

              # 3) Айтемы по каждой категории (каждая категория — своя линия)
              category_ids = @items.where.not(category_id: nil).pluck(:category_id).uniq
              Category.where(id: category_ids).each do |category|
                data << build_pdp_charts_data(@items.where(category: category), label: category.name)
              end

              data
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
          end
        end
      end
    end
  end
end
