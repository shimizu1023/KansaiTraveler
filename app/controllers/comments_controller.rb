class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))
    if @comment.save
      redirect_to @post, notice: t("comments.create.success")
    else
      @comments = @post.comments.includes(:user).order(:created_at)
      render "posts/show", status: :unprocessable_entity
    end
  end

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

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end