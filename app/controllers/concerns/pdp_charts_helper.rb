module PdpChartsHelper
  extend ActiveSupport::Concern

  #--------------------------------------------------------------------------
  # 1) ОДИН набор Items => ОДНА линия
  #
  #    Возвращает { label:, items_data:, wa_data:, effort_data: }
  #
  #    Логика:
  #    - Собираем IDs
  #    - Собираем quarters
  #    - 1 запрос -> получаем max(percent) для всех item_ids по всем кварталам
  #    - Считаем накопительный прогресс
  #--------------------------------------------------------------------------
  def build_pdp_charts_data(items, label: "Group")
    qtrs = filtered_quarters
    return empty_chart_data(label) if qtrs.blank?

    item_ids = items.map(&:id)
    effort_by_item_id = items.map { |it| [it.id, it.effort.to_f] }.to_h
    # => { 101 => 2.0, 102 => 0.5, ... }

    # 1 запрос на весь период (от самого раннего квартала до самого позднего)
    all_progress_map = _build_progress_map(item_ids, qtrs)
    # => { qtr_hash => { item_id => max_percent }, ... }

    items_data  = []
    wa_data     = []
    effort_data = []

    historical_max = {}  # { item_id => max_percent_до_текущего_квартала }

    qtrs.each do |q|
      per_quarter_map = all_progress_map[q] || {}
      items_count              = 0
      sum_of_diff_times_effort = 0.0
      sum_of_effort_for_active = 0.0

      items.each do |item|
        current_progress = per_quarter_map[item.id] || 0
        prev_max         = historical_max[item.id]   || 0

        if current_progress > prev_max
          diff = current_progress - prev_max
          items_count += 1

          w = effort_by_item_id[item.id]  # Берём из заранее подготовленного хеша
          sum_of_diff_times_effort += diff * w
          sum_of_effort_for_active  += w

          historical_max[item.id] = current_progress
        end
      end

      wa      = sum_of_effort_for_active.positive? ? (sum_of_diff_times_effort / sum_of_effort_for_active).round(2) : 0.0
      pdp_eff = (wa * sum_of_effort_for_active).round(2)

      x_date = q[:start]

      items_data  << { x: x_date, y: items_count }
      wa_data     << { x: x_date, y: wa }
      effort_data << { x: x_date, y: pdp_eff }
    end

    {
      label:       label,
      items_data:  items_data,
      wa_data:     wa_data,
      effort_data: effort_data
    }
  end

  #--------------------------------------------------------------------------
  # 2) НЕСКОЛЬКО групп Items (label => Items) => МАССИВ линий
  #
  #    Принимает хеш:
  #      {
  #        "All"         => #<ActiveRecord::Relation или массив>,
  #        "No Category" => ...,
  #        ...
  #      }
  #
  #    Возвращает массив:
  #      [
  #        { label: "All", items_data: [...], wa_data: [...], effort_data: [...] },
  #        { label: "No Category", ... },
  #        ...
  #      ]
  #
  #    Логика та же: один запрос на все item_ids и на весь период.
  #--------------------------------------------------------------------------
  def build_pdp_charts_data_for_sets(labels_and_items)
    qtrs = filtered_quarters
    return [] if qtrs.blank?

    # Собирать ВСЕ item_ids
    all_item_ids = labels_and_items.values.flat_map { |its| its.map(&:id) }.uniq

    # 1 запрос, чтобы получить max(percent) по кварталам
    all_progress_map = _build_progress_map(all_item_ids, qtrs)
    # => { qtr_hash => { item_id => max_percent }, ... }

    # Структура для результатов
    results = {}
    labels_and_items.each do |label, items|
      item_ids = items.map(&:id)
      effort_by_id = items.map { |it| [it.id, it.effort.to_f] }.to_h
      results[label] = {
        label:           label,
        items_data:      [],
        wa_data:         [],
        effort_data:     [],
        historical_max:  {},
        item_ids:        item_ids,
        effort_by_id:    effort_by_id  # { item_id => float }
      }
    end

    # Для каждого квартала раскладываем прогресс
    qtrs.each do |q|
      per_quarter_map = all_progress_map[q] || {}

      results.each do |_label, group_data|
        hist_max_map   = group_data[:historical_max]
        item_ids_array = group_data[:item_ids]
        effort_by_id   = group_data[:effort_by_id]

        items_count              = 0
        sum_of_diff_times_effort = 0.0
        sum_of_effort_for_active = 0.0

        item_ids_array.each do |item_id|
          current_progress = per_quarter_map[item_id] || 0
          prev_max         = hist_max_map[item_id] || 0

          if current_progress > prev_max
            diff = current_progress - prev_max
            items_count += 1

            w = effort_by_id[item_id] || 0.0
            sum_of_diff_times_effort += diff * w
            sum_of_effort_for_active  += w

            hist_max_map[item_id] = current_progress
          end
        end

        wa      = sum_of_effort_for_active.positive? ? (sum_of_diff_times_effort / sum_of_effort_for_active).round(2) : 0.0
        pdp_eff = (wa * sum_of_effort_for_active).round(2)

        x_date = q[:start]
        group_data[:items_data]  << { x: x_date, y: items_count }
        group_data[:wa_data]     << { x: x_date, y: wa }
        group_data[:effort_data] << { x: x_date, y: pdp_eff }
      end
    end

    # Превращаем results (hash) в массив
    results.values.map do |group_data|
      {
        label:       group_data[:label],
        items_data:  group_data[:items_data],
        wa_data:     group_data[:wa_data],
        effort_data: group_data[:effort_data]
      }
    end
  end

  #--------------------------------------------------------------------------
  # 3) "Константная" линия (как у вас было)
  #
  #    Возвращает { label:, items_data:, wa_data:, effort_data: }
  #    где нужный массив заполнен одинаковыми значениями, а остальные пусты
  #--------------------------------------------------------------------------
  def build_pdp_constant_line_data(value, label: "Line", chart_type: :effort)
    qtrs = filtered_quarters
    return empty_chart_data(label) if qtrs.blank?

    data_points = qtrs.map do |q|
      { x: q[:start], y: value }
    end

    # Вставляем в нужный массив, остальные пустые
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

  #--------------------------------------------------------------------------
  # (A) Если кварталов нет — пустая структура
  #--------------------------------------------------------------------------
  def empty_chart_data(label = "Group")
    {
      label:       label,
      items_data:  [],
      wa_data:     [],
      effort_data: []
    }
  end

  #--------------------------------------------------------------------------
  # (B) Список всех кварталов (2024–2025), как у вас было
  #--------------------------------------------------------------------------
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

  #--------------------------------------------------------------------------
  # (C) Фильтруем кварталы до текущей (включая текущую)
  #--------------------------------------------------------------------------
  def filtered_quarters
    now = Date.today
    quarters = all_quarters
    current_q = quarters.find { |q| q[:start] <= now && q[:end] >= now }
    return [] unless current_q

    idx = quarters.index(current_q)
    quarters[0..idx]
  end

  #--------------------------------------------------------------------------
  # (D) ОДИН запрос для получения max(percent) за диапазон дат
  #
  #     Возвращает структуру:
  #       {
  #         { name:..., start:..., end:... } => { item_id => max_percent, ... },
  #         ...
  #       }
  #--------------------------------------------------------------------------
  def _build_progress_map(item_ids, qtrs)
    return {} if item_ids.empty? || qtrs.empty?

    # 1) Общий диапазон дат — от самого первого квартала до самого последнего
    min_date = qtrs.first[:start]
    max_date = qtrs.last[:end]

    # 2) Грузим одним разом progress_updates (c датой колонки)
    raw_updates = ProgressUpdate
      .joins(:item_progress_column)
      .where(item_id: item_ids)
      .where(item_progress_columns: { date: min_date..max_date })
      .select('progress_updates.item_id, progress_updates.percent, item_progress_columns.date as column_date')

    # 3) Подготавливаем хеш по кварталам
    map_by_quarter = {}
    qtrs.each do |q|
      map_by_quarter[q] = {}  # потом тут будет {item_id => max_percent}
    end

    # 4) Распределяем каждый update в соответствующий квартал => берём максимум
    raw_updates.each do |pu|
      date = pu.column_date
      q = qtrs.find { |qt| qt[:start] <= date && date <= qt[:end] }
      next unless q

      current_item_id = pu.item_id
      current_percent = pu.percent || 0

      existing = map_by_quarter[q][current_item_id] || 0
      if current_percent > existing
        map_by_quarter[q][current_item_id] = current_percent
      end
    end

    map_by_quarter
  end
end
