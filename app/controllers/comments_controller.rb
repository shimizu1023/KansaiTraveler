class CommentsController < ApplicationController
  # コメント操作はログイン済みユーザーのみ許可する
  before_action :authenticate_user!
  before_action :set_post

  # 投稿に紐づくコメントを作成する
  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))
    if @comment.save
      redirect_to @post, notice: t("comments.create.success")
    else
      @comments = @post.comments.includes(:user).order(:created_at)
      render "posts/show", status: :unprocessable_entity
    end
  end

  # 自分のコメントのみを削除できるようにする
  def destroy
    comment = @post.comments.find(params[:id])
    unless comment.user_id == current_user.id
      redirect_to @post, alert: t("comments.destroy.forbidden"), status: :see_other
      return
    end

    comment.destroy
    redirect_to @post, notice: t("comments.destroy.success"), status: :see_other
  end

  private

  # コメント対象の投稿を読み込む
  def set_post
    @post = Post.find(params[:post_id])
  end

  # フォームから許可された項目だけを受け取る
  def comment_params
    params.require(:comment).permit(:content)
  end
end
