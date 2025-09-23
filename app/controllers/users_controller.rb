class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :set_user, only: [:show]

  def show
    @posts = @user.posts.includes(:category, images_attachments: :blob)
                  .visible_to(current_user)
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(12)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
