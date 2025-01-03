module PdpChartsHelper
  extend ActiveSupport::Concern

  # Example Chart Data Usage
  # Single Item:
  # @chart_data = [build_pdp_charts_data([@item], label: @item.name)]

  # Single user's items:
  # @chart_data = [build_pdp_charts_data(@user.items, label: @user.name)]

  # Many User Items:
  # @chart_data = @team.users.map do |u|
  #   build_pdp_charts_data(u.items, label: u.name)
  # end

  # Company-Wide User-Specific Items:
  # @chart_data = @company.users.map do |u|
  #  build_pdp_charts_data(u.items, label: u.name)
  # end

  # Company-Wide Team-Specific Items:
  # @chart_data = @company.teams.map do |t|
  #   label = "#{t.name} Team"
  #   users = t.users
  #   items = users.map(&:items).flatten
  #
  #   build_pdp_charts_data(items, label: label)
  # end

  # Build a single dataset for a "group" of items (which might be a single item or multiple).
  # Returns { label:, items_data:, wa_data:, effort_data: }
  def build_pdp_charts_data(items, label: "Group")
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
          0
        else
          prev_q = quarters[idx - 1]
          item.quarter_progress(prev_q[:start], prev_q[:end]) || 0
        end

        diff = current_progress - prev_progress
        if diff > 0
          items_count += 1
          w = item.effort.to_f
          sum_of_diff_times_effort += (diff * w)
          sum_of_effort_for_active  += w
        end
      end

      wa  = 0.0
      if sum_of_effort_for_active > 0
        wa = sum_of_diff_times_effort / sum_of_effort_for_active
      end

      pdp_eff = wa * sum_of_effort_for_active

      x_date = q[:start]

      itemsData  << { x: x_date, y: items_count }
      waData     << { x: x_date, y: wa.round(2) }
      effortData << { x: x_date, y: pdp_eff.round(2) }
    end

    {
      label: label,
      items_data:  itemsData,
      wa_data:     waData,
      effort_data: effortData
    }
  end
end
