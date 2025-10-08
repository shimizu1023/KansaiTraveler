class Bookmark < ApplicationRecord
  # ユーザーが気になる投稿を保存するための中間モデル
  belongs_to :user
  belongs_to :post, counter_cache: true

  # 同じ投稿を重複してブックマークできないよう制限
  validates :user_id, uniqueness: { scope: :post_id }
end
