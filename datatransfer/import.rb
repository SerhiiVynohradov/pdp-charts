# Pavlo Bernyk prod: 34
# Oleksii Berezhnyi: 35
# Petro Tretiak 36
# Serhii Vynohradov Gotoinc 37
# data = copypaste of import

# ID пользователя на проде, куда привязываем данные
PROD_USER_ID = 1
user = User.find(PROD_USER_ID)

# Допустим, у нас всё идёт в одну категорию (work).
# Пусть это айди категории, который ты заранее знаешь.
DEFAULT_CATEGORY_ID = 1

#
# 1) Создаём (или ищем) ItemProgressColumns
#
local_ipc_to_prod_id = {}

data[:item_progress_columns].each do |ipc_data|
  # Предположим, что у нас date уникальна для данного юзера.
  prod_ipc = user.item_progress_columns.find_or_create_by(date: Date.parse(ipc_data[:date]))
  local_ipc_to_prod_id[ipc_data[:local_id]] = prod_ipc.id
end

#
# 2) Создаём Items
#
local_item_to_prod_id = {}

data[:items].each do |item_data|
  # Поскольку решили не заморачиваться с категориями, ставим константу
  prod_item = user.items.create!(
    name:   item_data[:name],
    reason: item_data[:reason],
    effort: item_data[:effort],
    category_id: DEFAULT_CATEGORY_ID
  )

  local_item_to_prod_id[item_data[:local_id]] = prod_item.id
end

#
# 3) Создаём ProgressUpdates
#
data[:progress_updates].each do |pu_data|
  local_item_id  = pu_data[:local_item_id]
  local_ipc_id   = pu_data[:local_item_progress_column_id]
  percent        = pu_data[:percent]

  prod_item_id = local_item_to_prod_id[local_item_id]
  prod_ipc_id  = local_ipc_to_prod_id[local_ipc_id]

  next if prod_item_id.nil? || prod_ipc_id.nil?

  ProgressUpdate.create!(
    item_id: prod_item_id,
    item_progress_column_id: prod_ipc_id,
    percent: percent
  )
end

puts "Импорт данных завершён!"
