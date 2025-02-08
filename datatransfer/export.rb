u = User.find(1)

data = {}

# Собираем колонки
data[:item_progress_columns] = u.item_progress_columns.map do |ipc|
  {
    local_id: ipc.id,
    date: ipc.date.to_s
  }
end

# Собираем айтемы (только нужные поля)
data[:items] = u.items.map do |item|
  {
    local_id: item.id,
    name: item.name,
    reason: item.reason,
    category_id: item.category_id,
    effort: item.effort
  }
end

# Собираем апдейты
data[:progress_updates] = []
u.items.includes(:progress_updates).each do |item|
  item.progress_updates.each do |pu|
    data[:progress_updates] << {
      local_item_id: item.id,
      local_item_progress_column_id: pu.item_progress_column_id,
      percent: pu.percent
    }
  end
end

# Теперь выведем хеш в консоли, чтобы скопировать
puts data.inspect
