json.extract! suggestion, :id, :title, :description, :user_id, :created_at, :updated_at
json.url suggestion_url(suggestion, format: :json)
