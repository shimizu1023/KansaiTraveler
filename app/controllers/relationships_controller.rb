class RelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def create
    current_user.followings << @user unless current_user.followings.exists?(@user.id)
    redirect_back fallback_location: user_path(@user)
  end

  def destroy
    current_user.active_relationships.where(followed_id: @user.id).destroy_all
    redirect_back fallback_location: user_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
