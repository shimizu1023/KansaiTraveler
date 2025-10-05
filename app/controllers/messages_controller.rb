class MessagesController < ApplicationController
  # メッセージ送受信はログイン済みの参加者のみ許可する
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :authorize_participation!
  before_action :ensure_mutual_follow!

  # 会話に新しいメッセージを追加する
  def create
    @message = @conversation.messages.build(message_params.merge(user: current_user))
    if @message.save
      redirect_to @conversation
    else
      redirect_to @conversation, alert: @message.errors.full_messages.join(", ")
    end
  end

  private
    # 会話情報を取得する
    def set_conversation
      @conversation = Conversation.find(params[:conversation_id])
    end

    # フォームから許可された内容のみを受け取る
    def message_params
      params.require(:message).permit(:content)
    end

    # 参加者以外のアクセスを防ぐ
    def authorize_participation!
      return if @conversation.participant?(current_user)

      redirect_to conversations_path, alert: t("conversations.alerts.not_authorized")
    end

    # 相互フォローでない場合はメッセージを送れないようにする
    def ensure_mutual_follow!
      counterpart = @conversation.counterpart_for(current_user)
      return if current_user.mutual_follow?(counterpart)

      redirect_to conversations_path, alert: t("conversations.alerts.mutual_follow_required")
    end
end
