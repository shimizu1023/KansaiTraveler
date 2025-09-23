class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def create
    @message = @conversation.messages.build(message_params.merge(user: current_user))
    if @message.save
      redirect_to @conversation
    else
      redirect_to @conversation, alert: @message.errors.full_messages.join(", ")
    end
  end

  private
    def set_conversation
      @conversation = Conversation.find(params[:conversation_id])
    end

    def message_params
      params.require(:message).permit(:content)
    end
end


