class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :active_relationships, class_name: "Relationship", foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: :followed_id, dependent: :destroy
  has_many :followings, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  def display_name
    user_name.presence || name.presence || email.split("@").first
  end

  def following?(other_user)
    followings.exists?(other_user.id)
  end

  def mutual_follow?(other_user)
    return false if other_user.blank? || other_user == self

    following?(other_user) && other_user.following?(self)
  end

  def mutual_followees
    followings.includes(:followers).select { |other| mutual_follow?(other) }
  end
end
