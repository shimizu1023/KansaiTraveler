class Like < ApplicationRecord
  # 投稿に対する「いいね」を表すモデル
  belongs_to :user
  belongs_to :post, counter_cache: true

  # 同じ投稿に同じユーザーが複数回いいねできないよう制限
  validates :user_id, uniqueness: { scope: :post_id }
end
