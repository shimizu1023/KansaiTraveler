class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy

  validates :sender_id, uniqueness: { scope: :recipient_id }

  scope :between, ->(user_a, user_b) do
    where(sender: user_a, recipient: user_b)
      .or(where(sender: user_b, recipient: user_a))
  end

  scope :involving, ->(user) do
    where(sender: user).or(where(recipient: user))
  end

  def participant?(user)
    user_id = user&.id
    user_id.present? && (sender_id == user_id || recipient_id == user_id)
  end

  def counterpart_for(user)
    raise ArgumentError, "user must be a participant" unless participant?(user)

    sender_id == user.id ? recipient : sender
  end
end
