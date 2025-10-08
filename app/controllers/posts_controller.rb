class PostsController < ApplicationController
  # 各アクションの前に認証や必要な下準備を実行する
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_visibility!, only: :show
  before_action :authorize_owner!, only: %i[edit update destroy]
  before_action :prepare_form_resources, only: %i[new edit create update]

  # GET /posts
  # 絞り込み条件を組み合わせて投稿一覧をページングする
  def index
    @filter_params = filter_params
    @categories = Category.order(:name)
    @users = User.order(:name)

    scoped = Post.includes(:user, :category, images_attachments: :blob)
    @posts = apply_filters(scoped)
             .page(params[:page])
             .per(12)
  end

  # GET /posts/1
  # 閲覧数を集計しつつコメント投稿フォームを準備する
  def show
    increment_view_count!
    @comment = Comment.new
    @comments = @post.comments.includes(:user).order(:created_at)
  end

  # GET /posts/new
  # 下書き状態の新規投稿フォームを表示する
  def new
    @post = current_user.posts.build(status: :draft)
  end

  # GET /posts/1/edit
  def edit; end

  # POST /posts
  # 要求された公開ステータスで投稿を保存する
  def create
    @post = current_user.posts.build(post_params)
    @post.status = requested_status || :published

    if @post.save
      redirect_to post_redirect_path(@post), notice: t("posts.notices.created", status: status_label(@post))
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  # 画像の削除指定を考慮しながら投稿内容を更新する
  def update
    removal_ids = removal_image_ids
    @post.assign_attributes(post_params)
    @post.status = requested_status(@post) || @post.status

    if @post.save
      purge_images(removal_ids)
      redirect_to post_redirect_path(@post), notice: t("posts.notices.updated", status: status_label(@post))
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  # 投稿を削除し一覧へ戻す
  def destroy
    @post.destroy!
    redirect_to posts_path, notice: t("posts.notices.destroyed"), status: :see_other
  end

  private

  def set_post
    @post = Post.includes(:user, :category, :bookmarks, images_attachments: :blob).find(params[:id])
  end

  # 未公開投稿の閲覧権限を確認する
  def authorize_visibility!
    return if @post.published?
    return if user_signed_in? && @post.user_id == current_user.id

    redirect_to posts_path, alert: t("posts.alerts.unauthorized_draft"), status: :see_other
  end

  # 編集や削除が本人に限られるようにする
  def authorize_owner!
    return if user_signed_in? && @post.user_id == current_user.id

    redirect_to posts_path, alert: t("posts.alerts.forbidden"), status: :see_other
  end

  # フォームで使用するカテゴリ一覧を読み込む
  def prepare_form_resources
    @categories = Category.order(:name)
  end

  def filter_params
    params.permit(:q, :category_id, :user_id, :period, :sort, :status)
  end

  # 複数のスコープを組み合わせて検索条件を適用する
  def apply_filters(scope)
    scope = case @filter_params[:status]
            when "draft"
              user_signed_in? ? scope.draft_only.where(user_id: current_user.id) : scope.none
            when "published"
              scope.published_only
            when "bookmarked"
              user_signed_in? ? scope.bookmarked_by(current_user) : scope.none
            else
              scope.visible_to(current_user)
            end

    scope
      .with_keyword(@filter_params[:q])
      .with_category(@filter_params[:category_id])
      .with_user(@filter_params[:user_id])
      .within_period(@filter_params[:period])
      .sorted_by(@filter_params[:sort])
  end

  def post_params
    params.require(:post).permit(:category_id, :post, images: [])
  end

  def removal_image_ids
    params.fetch(:post, {}).fetch(:remove_image_ids, []).reject(&:blank?)
  end

  # 指定された画像 ID を基に添付ファイルを削除する
  def purge_images(ids)
    ids.each do |id|
      attachment = @post.images.attachments.find { |image| image.id.to_s == id.to_s }
      attachment&.purge_later
    end
  end

  # 画面から受け取った公開状態をシンボルに変換する
  def requested_status(post = nil)
    case params[:next_status]
    when "draft"
      :draft
    when "published"
      :published
    else
      post&.status&.to_sym
    end
  end

  # 閲覧済みセッションを確認しながら閲覧数を加算する
  def increment_view_count!
    return if user_signed_in? && current_user.id == @post.user_id

    session[:viewed_post_ids] ||= []
    return if session[:viewed_post_ids].include?(@post.id)

    @post.increment!(:views_count)
    session[:viewed_post_ids] << @post.id
  end

  def status_label(post)
    t("enums.post.status.#{post.status}")
  end

  # 公開状態に応じて遷移先を出し分ける
  def post_redirect_path(post)
    if post.published?
      post
    else
      edit_post_path(post)
    end
  end
end
