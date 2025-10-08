class RelationshipsController < ApplicationController
  # フォロー操作はログイン済みユーザーのみ
  before_action :authenticate_user!
  before_action :set_user

  # まだフォローしていない場合のみフォロー関係を作成する
  def create
    current_user.followings << @user unless current_user.followings.exists?(@user.id)
    redirect_back fallback_location: user_path(@user)
  end

  # 対象ユーザーへのフォローを解除する
  def destroy
    current_user.active_relationships.where(followed_id: @user.id).destroy_all
    redirect_back fallback_location: user_path(@user)
  end

  private

  # 対象となるユーザーを取得する
  def set_user
    @user = User.find(params[:user_id])
  end
end
