class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    like = @post.likes.find_or_initialize_by(user: current_user)
    like.save
    redirect_to @post, status: :see_other
  end

  def destroy
    like = @post.likes.find_by!(user: current_user)
    like.destroy
    redirect_to @post, status: :see_other
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end