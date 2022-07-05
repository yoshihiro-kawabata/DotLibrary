class MessagesController < ApplicationController
    before_action :set_message, only: [:show, :destroy]
    before_action :set_q, only: [:stock, :search]
    before_action :login_required
    skip_before_action :library_required
    before_action :store_required, only: [:stock, :search]
    before_action :provider_required, only: [:stock, :search]


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
      unless @message.user_id == @current_user.id or @message.create_id == @current_user.id 
        redirect_to messages_path, notice: 'そのメッセージにはアクセスできません。'
      end  

      if @message.user_id == @current_user.id
          @message.update(read_flg: true)
      end
    end

    def ship
      @messages = Message.select(:id,:user_name,:content,:read_flg).where(create_id:@current_user.id).order("created_at DESC").page params[:page]        
    end

    def destroy
      @message.destroy
      redirect_to messages_path, notice: 'メッセージを削除しました'
    end  

    def alldel
      @messages = Message.where(id: params[:mes]).delete_all
      redirect_to messages_path, notice: 'メッセージを削除しました'
    end  

    def allshow
      @messages = Message.where(id: params[:mes]).update_all(read_flg: true)
      redirect_to messages_path, notice: 'すべて既読にしました'
    end  

    def stock
      @books =[]
      @sen = @q.result.order("name ASC")
        @sen.each do |book|
          allib = []
          case @c_job.authority_id 
            when 1 then #司書
              alBolib = BooksLibrary.find_by(book_id:book.id, library_id:@current_job.id)
            else 
              alBolib = nil
          end
          if alBolib.present?
            allib << book.name
            allib << book.keyword1
            allib << book.keyword2
            allib << book.keyword3
            allib << book.keyword4
            allib << book.keyword5
            allib << alBolib.quantity
            allib << alBolib.remark
            allib << book.id
            @books << allib
          end    
        end
      end
      
    def search
      @books =[]
      @sen = @q.result.order("name ASC")
        @sen.each do |book|
          allib = []
          case @c_job.authority_id 
            when 1 then #司書
              alBolib = BooksLibrary.find_by(book_id:book.id, library_id:@current_job.id)
            else 
              alBolib = nil
          end
          if alBolib.present?
            allib << book.name
            allib << book.keyword1
            allib << book.keyword2
            allib << book.keyword3
            allib << book.keyword4
            allib << book.keyword5
            allib << alBolib.quantity
            allib << alBolib.remark
            allib << book.id
            @books << allib
          end    
        end
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

      def set_q
        @q = Book.ransack(params[:q])
      end


end
