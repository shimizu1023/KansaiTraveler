class Post < ApplicationRecord
  # 添付画像や公開状態を持つ旅行記の投稿モデル
  MAX_IMAGE_COUNT = 6
  MAX_IMAGE_SIZE = 5.megabytes
  MAX_CONTENT_LENGTH = 2000

  # フォームで削除指定された画像 ID を一時的に保持するためのアクセサ
  attr_accessor :remove_image_ids

  belongs_to :user
  belongs_to :category
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many_attached :images

  enum status: { published: 0, draft: 1 }

  # 投稿本文・公開状態・カテゴリの必須チェックと添付画像のバリデーション
  validates :post, presence: true, length: { maximum: MAX_CONTENT_LENGTH }
  validates :status, presence: true
  validates :category, presence: true
  validate :validate_images_count
  validate :validate_images_content_type
  validate :validate_images_byte_size

  # 一覧表示で使用する各種スコープ
  scope :published_only, -> { where(status: statuses[:published]) }
  scope :draft_only, -> { where(status: statuses[:draft]) }
  scope :visible_to, lambda { |user|
    published = arel_table[:status].eq(statuses[:published])
    return where(published) unless user

    draft_owned = arel_table[:status].eq(statuses[:draft]).and(arel_table[:user_id].eq(user.id))
    where(published.or(draft_owned))
  }
  scope :with_keyword, lambda { |q|
    return all if q.blank?

    where("post LIKE :keyword", keyword: "%#{sanitize_sql_like(q)}%")
  }
  scope :with_category, ->(category_id) { category_id.present? ? where(category_id: category_id) : all }
  scope :with_user, ->(user_id) { user_id.present? ? where(user_id: user_id) : all }
  scope :within_period, lambda { |period|
    case period
    when "today"
      where(arel_table[:created_at].gteq(Time.current.beginning_of_day))
    when "week"
      where(arel_table[:created_at].gteq(1.week.ago))
    when "month"
      where(arel_table[:created_at].gteq(1.month.ago))
    when "year"
      where(arel_table[:created_at].gteq(1.year.ago))
    else
      all
    end
  }
  scope :sorted_by, lambda { |sort|
    case sort
    when "popular"
      order(likes_count: :desc, views_count: :desc, created_at: :desc)
    else
      order(created_at: :desc)
    end
  }

  paginates_per 9 if respond_to?(:paginates_per)

  # 投稿のサムネイルとして最初の画像を返す
  def cover_image
    images.first if images.attached?
  end

  private

  # バリデーション対象の添付画像から削除指定分を除外する
  def attachments_for_validation
    ids_to_remove = Array(remove_image_ids).map(&:to_s)
    images.attachments.reject { |attachment| ids_to_remove.include?(attachment.id.to_s) }
  end

  # 添付画像の枚数が上限を超えていないか確認する
  def validate_images_count
    return unless attachments_for_validation.size > MAX_IMAGE_COUNT

    errors.add(:images, :too_many, count: MAX_IMAGE_COUNT)
  end

  # 添付画像のファイル形式をチェックする
  def validate_images_content_type
    invalid = attachments_for_validation.any? do |attachment|
      !attachment.content_type.in?(%w[image/png image/jpeg image/jpg image/gif])
    end
    errors.add(:images, :invalid_content_type) if invalid
  end

  # 添付画像のファイルサイズが制限内か確認する
  def validate_images_byte_size
    oversize = attachments_for_validation.any? do |attachment|
      attachment.byte_size.present? && attachment.byte_size > MAX_IMAGE_SIZE
    end
    errors.add(:images, :file_size_out_of_range, limit: (MAX_IMAGE_SIZE / 1.megabyte).to_i) if oversize
  end
end
