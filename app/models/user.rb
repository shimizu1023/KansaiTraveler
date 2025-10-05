class User < ApplicationRecord
  # Devise を利用したユーザー認証と基本的なアカウント機能
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :active_relationships, class_name: "Relationship", foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: :followed_id, dependent: :destroy
  has_many :followings, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  # 表示名をユーザー名→氏名→メールアドレスの順に決定する
  def display_name
    user_name.presence || name.presence || email.split("@").first
  end

  # 指定ユーザーをフォローしているか確認する
  def following?(other_user)
    followings.exists?(other_user.id)
  end

  # 相互フォローかどうかを判定する（自分自身は除外）
  def mutual_follow?(other_user)
    return false if other_user.blank? || other_user == self

    following?(other_user) && other_user.following?(self)
  end

  # 相互フォローになっているユーザー一覧を取得する
  def mutual_followees
    followings.includes(:followers).select { |other| mutual_follow?(other) }
  end
end
