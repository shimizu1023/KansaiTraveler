class ConversationsController < ApplicationController
  # DM は相互フォローかつ当事者のみが操作できる
  before_action :authenticate_user!
  before_action :set_target_user_for_create, only: :create
  before_action :set_conversation, only: :show
  before_action :authorize_participation!, only: :show
  before_action :ensure_mutual_follow!, only: [:create, :show]

  # 相互フォロー相手との会話一覧を最新順で取得する
  def index
    @conversations = Conversation
      .involving(current_user)
      .includes(:sender, :recipient, messages: :user)
      .order(updated_at: :desc)
      .select { |conversation| current_user.mutual_follow?(conversation.counterpart_for(current_user)) }

    counterpart_ids = @conversations.map { |conversation| conversation.counterpart_for(current_user).id }
    @startable_users = current_user.mutual_followees.reject { |user| counterpart_ids.include?(user.id) }
  end

  # 会話の詳細とメッセージ一覧を表示する
  def show
    @counterpart = @conversation.counterpart_for(current_user)
    @messages = @conversation.messages.includes(:user)
    @message = Message.new
  end

  # 既存会話を再利用しつつ新しい会話を開始する
  def create
    conversation = Conversation.between(current_user, @target_user).first_or_initialize

    if conversation.new_record?
      conversation.sender = current_user
      conversation.recipient = @target_user
      conversation.save!
    end

    redirect_to conversation
  end

  private
    # 作成時に対象ユーザーを特定する
    def set_target_user_for_create
      @target_user = User.find(params[:recipient_id])
    end

    # 表示対象の会話を読み込む
    def set_conversation
      @conversation = Conversation.find(params[:id])
    end

    # 当事者以外のアクセスを拒否する
    def authorize_participation!
      return if @conversation.participant?(current_user)

      redirect_to conversations_path, alert: t("conversations.alerts.not_authorized")
    end

    # 相互フォローでない場合は会話を許可しない
    def ensure_mutual_follow!
      target_user = @target_user || @conversation.counterpart_for(current_user)
      return if current_user.mutual_follow?(target_user)

      fallback = action_name == "create" ? user_path(target_user) : conversations_path
      redirect_back fallback_location: fallback, alert: t("conversations.alerts.mutual_follow_required")
    end
end
