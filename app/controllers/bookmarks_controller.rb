class BookmarksController < ApplicationController
  # ブックマーク操作はログイン済みユーザーに限定する
  before_action :authenticate_user!
  before_action :set_post

  # 投稿をブックマークへ追加する
  def create
    bookmark = @post.bookmarks.find_or_initialize_by(user: current_user)
    bookmark.save
    redirect_back fallback_location: post_path(@post), status: :see_other
  end

  # 追加済みのブックマークを解除する
  def destroy
    bookmark = @post.bookmarks.find_by!(user: current_user)
    bookmark.destroy
    redirect_back fallback_location: post_path(@post), status: :see_other
  end

  private

  # 対象となる投稿を取得する
  def set_post
    @post = Post.find(params[:post_id])
  end
end
