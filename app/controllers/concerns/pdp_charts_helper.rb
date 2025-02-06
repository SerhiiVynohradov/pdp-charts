module PdpChartsHelper
  extend ActiveSupport::Concern

  # Основной метод – строит данные на основе реальных айтемов
  # Возвращает { label:, items_data:, wa_data:, effort_data: }
  def build_pdp_charts_data(items, label: "Group")
    qtrs = filtered_quarters
    return empty_chart_data(label) if qtrs.blank?

    itemsData  = []
    waData     = []
    effortData = []

    historical_max = {} # Для отслеживания исторического максимума прогресса каждого айтема

    qtrs.each do |q|
      items_count              = 0
      sum_of_diff_times_effort = 0.0
      sum_of_effort_for_active = 0.0

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

      wa     = sum_of_effort_for_active.positive? ? (sum_of_diff_times_effort / sum_of_effort_for_active).round(2) : 0.0
      pdp_eff = (wa * sum_of_effort_for_active).round(2)

      x_date = q[:start]
      itemsData  << { x: x_date, y: items_count }
      waData     << { x: x_date, y: wa }
      effortData << { x: x_date, y: pdp_eff }
    end

    {
      label:       label,
      items_data:  itemsData,
      wa_data:     waData,
      effort_data: effortData
    }
  end

  # Метод для построения "константной" линии на одном из трёх графиков:
  # chart_type: :items, :wa, или :effort
  #
  # Пример вызова:
  #   build_pdp_constant_line_data(1000, label: "Лінія ризику вигоряння", chart_type: :effort)
  #
  # Вернёт объект вида { label:, items_data:, wa_data:, effort_data: },
  # где заполнен только нужный массив (остальные – пустые).
  def build_pdp_constant_line_data(value, label: "Line", chart_type: :effort)
    qtrs = filtered_quarters
    return empty_chart_data(label) if qtrs.blank?

    data_points = qtrs.map do |q|
      { x: q[:start], y: value }
    end

    # Собираем результат таким образом, чтобы линия попала ТОЛЬКО в нужный график
    items_data  = (chart_type == :items  ? data_points : [])
    wa_data     = (chart_type == :wa     ? data_points : [])
    effort_data = (chart_type == :effort ? data_points : [])

    {
      label:       label,
      items_data:  items_data,
      wa_data:     wa_data,
      effort_data: effort_data
    }
  end

  private

  # Пустой объект, если текущая дата выходит за диапазон кварталов (или нет кварталов)
  def empty_chart_data(label = "Group")
    {
      label:       label,
      items_data:  [],
      wa_data:     [],
      effort_data: []
    }
  end

  # Все кварталы 2024–2025
  def all_quarters
    [
      { name: "Q1 2024", start: Date.new(2024,1,1),  end: Date.new(2024,3,31) },
      { name: "Q2 2024", start: Date.new(2024,4,1),  end: Date.new(2024,6,30) },
      { name: "Q3 2024", start: Date.new(2024,7,1),  end: Date.new(2024,9,30) },
      { name: "Q4 2024", start: Date.new(2024,10,1), end: Date.new(2024,12,31) },
      { name: "Q1 2025", start: Date.new(2025,1,1),  end: Date.new(2025,3,31) },
      { name: "Q2 2025", start: Date.new(2025,4,1),  end: Date.new(2025,6,30) },
      { name: "Q3 2025", start: Date.new(2025,7,1),  end: Date.new(2025,9,30) },
      { name: "Q4 2025", start: Date.new(2025,10,1), end: Date.new(2025,12,31) }
    ]
  end

  # Возвращаем массив кварталов с начала 2024 до текущего включительно
  def filtered_quarters
    now = Date.today
    quarters = all_quarters
    current_q = quarters.find { |q| q[:start] <= now && q[:end] >= now }

    if current_q
      idx = quarters.index(current_q)
      quarters[0..idx]
    else
      # Если текущая дата раньше первого квартала 2024 или позже последнего квартала 2025
      # (то есть вообще не попадает в кварталы) – вернём пустой
      []
    end
  end
end
