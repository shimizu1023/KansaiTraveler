class Relationship < ApplicationRecord
  # ユーザー同士のフォロー関係を表すモデル
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # 同じ組み合わせでの重複フォローを禁止する
  validates :follower_id, uniqueness: { scope: :followed_id }
end
