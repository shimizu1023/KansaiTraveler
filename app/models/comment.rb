class Comment < ApplicationRecord
  # 投稿に紐づくコメントを表すモデル
  belongs_to :user
  belongs_to :post

  validates :content, presence: true, length: { maximum: 2000 }
end
