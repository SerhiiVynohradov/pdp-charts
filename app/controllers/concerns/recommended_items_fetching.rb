module RecommendedItemsFetching
  extend ActiveSupport::Concern

  included do
  end

  def index
    query = params[:search].to_s.strip
    return render json: [] if query.blank?

    user = @user || current_user

    recommended_items = fetch_recommended_items_for(user, query)

    render json: recommended_items.map { |ri|
      {
        id:            ri.id,
        name:          ri.name,
        description:   ri.description,
        effort:        ri.effort,
        category_id:   ri.category_id,
        category_name: ri.category&.name
      }
    }
  end

  private

  def fetch_recommended_items_for(user, query)
    team_id    = user.team_id
    company_id = user.team&.company_id

    team_items = []
    company_items = []
    global_items = []

    if team_id.present?
      team_items = RecommendedItem
        .where(team_id: team_id)
        .where("name ILIKE ?", "%#{query}%")
    end

    if company_id.present?
      company_items = RecommendedItem
        .where(company_id: company_id)
        .where("name ILIKE ?", "%#{query}%")
    end

    global_items = RecommendedItem
      .where(team_id: nil, company_id: nil)
      .where("name ILIKE ?", "%#{query}%")

    team_items = team_items.sort_by { |ri| ri.name.downcase }
    company_items = company_items.sort_by { |ri| ri.name.downcase }
    global_items = global_items.sort_by { |ri| ri.name.downcase }

    results = team_items + company_items + global_items
    results.first(20)
  end
end
