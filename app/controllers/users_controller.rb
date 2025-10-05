class UsersController < ApplicationController
  # プロフィール表示はログイン済みユーザーに限定する
  before_action :authenticate_user!, only: [:show]
  before_action :set_user, only: [:show]

  # ユーザーの公開投稿を新しい順で一覧表示する
  def show
    @posts = @user.posts.includes(:category, images_attachments: :blob)
                  .visible_to(current_user)
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(12)
  end

  private

  # 表示対象のユーザーを取得する
  def set_user
    @user = User.find(params[:id])
  end
end
