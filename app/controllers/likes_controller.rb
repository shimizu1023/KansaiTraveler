class LikesController < ApplicationController
  # いいね操作にはログインが必要
  before_action :authenticate_user!
  before_action :set_post

  # まだ存在しない場合にいいねを付与する
  def create
    like = @post.likes.find_or_initialize_by(user: current_user)
    like.save
    redirect_to @post, status: :see_other
  end

  # 自分のいいねを取り消す
  def destroy
    like = @post.likes.find_by!(user: current_user)
    like.destroy
    redirect_to @post, status: :see_other
  end

  private

  # 対象の投稿を取得する
  def set_post
    @post = Post.find(params[:post_id])
  end
end
