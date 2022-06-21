class MessagesController < ApplicationController
    before_action :set_message, only: [:show, :destroy]
    before_action :login_required

    def index
        @messages = Message.where(user_id: @current_user.id).order("created_at DESC").page params[:page]        
    end

    def new
          @message = Message.new
          user_select
    end
  
    def create
        @message = Message.new(message_params)
        use_auth = UsersAuthority.find_by(user_id: @message.user_id)
        if use_auth.present?
          case use_auth.authority_id 
              when 1 then #司書
                sub_user = Library.find_by(user_id: @message.user_id)
              when 2 then #書店
                sub_user = Store.find_by(user_id: @message.user_id)
              when 3 then #個人提供者
                sub_user = Provider.find_by(user_id: @message.user_id)
          end
        else
          sub_user = Store.new
        end  

        @message.create_name = current_user.name
        @message.create_id = @current_user.id
        @message.user_name = sub_user.name

        if @message.save
          flash[:notice] = 'メッセージを作成しました'
          redirect_to messages_path
        else
          user_select
          flash[:notice] = 'メッセージを作成に失敗しました'
          render :new
        end
    end

    def show
      if @message.user_id == @current_user.id
          @message.update(read_flg: true)
      end
    end

    def destroy
      @message.destroy
      redirect_to messages_path, notice: 'メッセージを削除しました'
    end  

    def alldel
      @messages = Message.where(id: params[:mes]).delete_all
      redirect_to messages_path, notice: '受信メッセージを削除しました'
    end  

    def allshow
      @messages = Message.where(id: params[:mes]).update_all(read_flg: true)
      redirect_to messages_path, notice: 'すべて既読にしました'
    end  

    private  
      def message_params
        params.require(:message).permit(:user_id, :content)
      end

      def set_message
        @message = Message.find(params[:id])        
      end

      def user_select
        @users = User.where.not(id: @current_user.id).order("id ASC")
        @sub_users = []
        @users.each do |user|
          sub_box = []
          use_auth = UsersAuthority.find_by(user_id: user.id)
          if use_auth.present?
            case use_auth.authority_id 
                when 1 then #司書
                  sub_user = Library.find_by(user_id: user.id)
                when 2 then #書店
                  sub_user = Store.find_by(user_id: user.id)
                when 3 then #個人提供者
                  sub_user = Provider.find_by(user_id: user.id)
            end
          else
            sub_user = Store.new
          end  
          sub_box << sub_user.name
          sub_box << user.id
          @sub_users << sub_box
        end
      end

end
