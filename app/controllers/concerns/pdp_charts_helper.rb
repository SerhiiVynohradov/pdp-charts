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
    # Определяем фиксированные кварталы для 2024 и 2025 годов
    # Мы не можем иметь не-фиксированные агрегаторы прогресса,
    # потому что тогда у нас начинают плавать нормативы,
    # и теряется смысл и главный плюс бизнес-модели
    # (предсказание того сколько считать нормой чтоб предсказать выгорит человек или нет)

    quarters = [
      { name: "Q1 2024", start: Date.new(2024,1,1),  end: Date.new(2024,3,31) },
      { name: "Q2 2024", start: Date.new(2024,4,1),  end: Date.new(2024,6,30) },
      { name: "Q3 2024", start: Date.new(2024,7,1),  end: Date.new(2024,9,30) },
      { name: "Q4 2024", start: Date.new(2024,10,1), end: Date.new(2024,12,31) },
      { name: "Q1 2025", start: Date.new(2025,1,1),  end: Date.new(2025,3,31) },
      { name: "Q2 2025", start: Date.new(2025,4,1),  end: Date.new(2025,6,30) },
      { name: "Q3 2025", start: Date.new(2025,7,1),  end: Date.new(2025,9,30) },
      { name: "Q4 2025", start: Date.new(2025,10,1), end: Date.new(2025,12,31) }
    ]

    # Определяем текущую дату
    current_date = Date.today

    # Определяем текущий квартал
    current_quarter = quarters.find { |q| q[:start] <= current_date && q[:end] >= current_date }

    # Отфильтровываем кварталы до текущего (включительно)
    if current_quarter
      current_quarter_index = quarters.index(current_quarter)
      filtered_quarters = quarters[0..current_quarter_index]
    else
      # Если текущая дата вне всех кварталов (например, до Q1 2024), оставляем пустой массив
      filtered_quarters = []
    end

    itemsData  = []
    waData     = []
    effortData = []

    historical_max = {} # Хэш для отслеживания исторического максимума прогресса каждого айтема

    filtered_quarters.each_with_index do |q, idx|
      items_count                  = 0
      sum_of_diff_times_effort     = 0.0
      sum_of_effort_for_active     = 0.0

      items.each do |item|
        current_progress = item.quarter_progress(q[:start], q[:end])
        prev_max = historical_max[item.id] || 0

        if current_progress > prev_max
          diff = current_progress - prev_max
          items_count += 1
          w = item.effort.to_f
          sum_of_diff_times_effort += (diff * w)
          sum_of_effort_for_active  += w

          # Обновляем исторический максимум
          historical_max[item.id] = current_progress
        else
          diff = 0
          # Исторический максимум не изменяется
        end
      end

      wa  = sum_of_effort_for_active.positive? ? (sum_of_diff_times_effort / sum_of_effort_for_active).round(2) : 0.0
      pdp_eff = (wa * sum_of_effort_for_active).round(2)

      x_date = q[:start]

      itemsData  << { x: x_date, y: items_count }
      waData     << { x: x_date, y: wa }
      effortData << { x: x_date, y: pdp_eff }
    end

    {
      label: label,
      items_data:  itemsData,
      wa_data:     waData,
      effort_data: effortData
    }
  end
end
