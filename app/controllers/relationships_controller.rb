class RelationshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    user = User.find(params[:user_id])
    current_user.followings << user unless current_user.followings.exists?(user.id)
    redirect_back fallback_location: root_path
  end

  def destroy
    user = User.find(params[:user_id])
    current_user.active_relationships.where(followed_id: user.id).destroy_all
    redirect_back fallback_location: root_path
  end
end


