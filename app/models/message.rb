class Message < ApplicationRecord
  # 会話内で送受信されるメッセージを表すモデル
  belongs_to :conversation
  belongs_to :user

  validates :content, presence: true
end
