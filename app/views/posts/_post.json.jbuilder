json.extract! post, :id, :user_id, :category_id, :post, :status, :created_at, :updated_at
json.url post_url(post, format: :json)
