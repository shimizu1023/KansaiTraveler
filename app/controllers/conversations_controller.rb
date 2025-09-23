class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @conversations = Conversation.where("sender_id = :id OR recipient_id = :id", id: current_user.id)
  end

  def show
    @conversation = Conversation.find(params[:id])
  end

  def create
    recipient = User.find(params[:recipient_id])
    conversation = Conversation.find_or_create_by!(sender: current_user, recipient: recipient)
    redirect_to conversation
  end
end


