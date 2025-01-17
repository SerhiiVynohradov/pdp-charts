class RecommendedItemsController < ApplicationController
  def index
    query = params[:search].to_s.strip
    return render json: [] if query.blank?

    # Пример простого поиска
    recommended_items = RecommendedItem.where("name ILIKE ?", "%#{query}%")
                                       .order(:name)
                                       .limit(20)

    render json: recommended_items.map { |ri|
      { id: ri.id,
        name: ri.name,
        description: ri.description,
        effort: ri.effort,
        category_id: ri.category_id,
        category_name: ri.category&.name
      }
    }
  end
end
