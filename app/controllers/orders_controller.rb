class OrdersController < ApplicationController
      before_action :login_required
      before_action :set_order, only: [:show, :edit, :update]
      before_action :set_q, only: [:choice, :search, :make, :create]
      before_action :set_search, only: [:choice, :search, :make, :create]
      before_action :set_choice, only: [:choice]
      before_action :set_make, only: [:make, :create]

      def index
        case @c_job.authority_id 
        when 1 then #図書館
          @orders = Order.where(user_id: @current_user.id, complete_flg: false).order("updated_at DESC")
          @orders.each do |order|
            order.user_name = order.receive_user_name
            select_time_index(order)
          end
        else
          @orders = Order.where(receive_user_id: @current_user.id, complete_flg: false).where("number > ?", 1).order("updated_at DESC")
          @orders.each do |order|
            select_time_index(order)
          end
        end
      end

      def history
        case @c_job.authority_id 
        when 1 then #図書館
          @orders = Order.where(user_id: @current_user.id, complete_flg: true).order("updated_at DESC")
        else
          @orders = Order.where(receive_user_id: @current_user.id, complete_flg: true).order("updated_at DESC")
        end
      end


      def talk
        @order = Order.find(params[:order_id])
        @comment = Comment.new
        @talks = Comment.where(order_id: @order.id).order("created_at ASC")
      end

      def show
      end

      def edit
      end
  
      def update

        order_up = @order

        select_number(order_up)
              
        case @order.number 
        when 3 then 
           order_up.ord_limit = params[:order][:ord_limit]
           order_up.condition = params[:order][:condition]

           detail_box = []
           3.times do |n|
            @detail_n = Detail.new
            case n 
            when 0 then 
              @detail_n.name = "送料"
              @detail_n.quantity = 0
              @detail_n.price = params[:order][:postage]
              @detail_n.remark = "送料"
              @detail_n.order_id = order_up.id
            when 1 then 
              @detail_n.name = "装備費"
              @detail_n.quantity = 0
              @detail_n.price = params[:order][:equipment]
              @detail_n.remark = "装備費用"
              @detail_n.order_id = order_up.id
            when 2 then 
              @detail_n.name = "その他"
              @detail_n.quantity = 0
              @detail_n.price = params[:order][:other]
              @detail_n.remark = params[:order][:other_remark]
              @detail_n.order_id = order_up.id
            end
            detail_box << @detail_n
           end

           if order_up.valid?
            detail_box.each do |deta|
              if deta.invalid?
                deta.errors.full_messages.each do |message|
                  messageA = "：" + message
                  @detail.errors.add(deta.name, messageA)
                end
              end
            end
  
            if @detail.errors.present?
              flash[:notice] = '受発注情報が更新できませんでした'
              render :edit    
            else
              order_up.title = "【" + params[:order][:number] + "】" + @current_job.name + "_" + DateTime.now.strftime('%Y年%m月%d日%H時%M分')
              order_up.price = @order.price + params[:order][:postage].to_i + params[:order][:equipment].to_i + params[:order][:other].to_i
              @order.update(title: order_up.title,number: order_up.number, ord_limit: order_up.ord_limit, condition: order_up.condition, price: order_up.price)
              detail_box.each do |deta|
                deta.order_id = @order.id
                deta.save
              end
              flash[:notice] = '受発注情報の更新が完了しました'
              redirect_to talk_orders_path(order_id: @order.id)
            end
          else
            flash[:notice] = '受発注情報が更新できませんでした'
            render :edit    
          end
        when 12 then 
          order_up.title = "【" + params[:order][:number] + "】" + @current_job.name + "_" + DateTime.now.strftime('%Y年%m月%d日%H時%M分')
          order_up.price = @order.price + params[:order][:postage].to_i + params[:order][:equipment].to_i + params[:order][:other].to_i
          order_up.complete_flg = true
          if @order.update(title: order_up.title, number: order_up.number, complete_flg: order_up.complete_flg)
            flash[:notice] = '受発注が完了しました'
            redirect_to orders_path
          else
            flash[:notice] = '受発注情報が更新できませんでした'
            render :edit    
          end
        else
          order_up.title = "【" + params[:order][:number] + "】" + @current_job.name + "_" + DateTime.now.strftime('%Y年%m月%d日%H時%M分')
          if @order.update(title: order_up.title, number: order_up.number)
            flash[:notice] = '受発注情報の更新が完了しました'
            redirect_to talk_orders_path(order_id: @order.id)
          else
            flash[:notice] = '受発注情報が更新できませんでした'
            render :edit    
          end
        end
      end

      def search
      end

      def choice
        flash[:notice] = nil
      end

      def make
        @order = Order.new
        @detail = Detail.new
        flash[:notice] = nil
      end

      def new
      end
  
      def create

        @order = Order.new(order_params)
        @detail = Detail.new

        detail_box = []

        @order.title = "【" + params[:order][:number] + "】" + @current_job.name + "_" + DateTime.now.strftime('%Y年%m月%d日%H時%M分')
        @order.user_id = @current_user.id
        @order.user_name = @current_job.name
        @order.complete_flg = false

        @order.price = 0

          case @use_auth.authority_id 
            when 2 then #書店
              @sub_user = Store.find_by(user_id: @userA.id)
              @order.receive_user_id = @sub_user.user_id
              @order.receive_user_name = @sub_user.name
              @book_select.size.times do |n|
                bosto = BooksStore.find_by(book_id:@book_select[n])
                bookA = Book.find(@book_select[n])
                if bookA.present?
                  @detail_n = Detail.new
                  @detail_n.name = bookA.name
                  if params[:order][:quantities][n].to_i > bosto.quantity
                    @detail.errors.add(bookA.name, "：希望在庫数が既存在庫数を上回っています")
                    @detail_n.quantity = 0
                  else
                    @detail_n.quantity = params[:order][:quantities][n]
                  end
                  @detail_n.price = bosto.price
                  @detail_n.remark = "---"
                  @detail_n.order_id = 0

                  if @detail_n.quantity.present?
                    @order.price += @detail_n.quantity * @detail_n.price
                  end
                  detail_box << @detail_n
                end    
              end

            when 3 then #個人提供者
              @sub_user = Provider.find_by(user_id: @userA.id)
              @order.receive_user_id = @sub_user.user_id
              @order.receive_user_name = @sub_user.name

              @book_select.size.times do |n|
                bopro = BooksProvider.find_by(book_id:@book_select[n])
                bookA = Book.find(@book_select[n])
                if bookA.present?
                  @detail_n = Detail.new
                  @detail_n.name = bookA.name
                  if params[:order][:quantities][n].to_i > bopro.quantity
                    @detail.errors.add(bookA.name, "：希望在庫数が既存在庫数を上回っています")
                    @detail_n.quantity = 0
                  else
                    @detail_n.quantity = params[:order][:quantities][n]
                  end
                  @detail_n.price = 0
                  @detail_n.remark = params[:order][:remarks][n]
                  @detail_n.order_id = 0

                  detail_box << @detail_n
                end    
              end
          end

        if params[:order][:number] == "未依頼"
          @order.number = 1
        else
          @order.number = 2
        end

        if @order.valid?
          detail_box.each do |deta|
            if deta.invalid?
              deta.errors.full_messages.each do |message|
                messageA = "：" + message
                @detail.errors.add(deta.name, messageA)
              end
            end
          end

          if @detail.errors.present?
            flash[:notice] = '受発注情報が登録できませんでした'
            render :make    
          else
            @order.save
            detail_box.each do |deta|
              deta.order_id = @order.id
              deta.save
            end
            flash[:notice] = '受発注情報の登録が完了しました'
            redirect_to mypage_users_path
          end
        else
          flash[:notice] = '受発注情報が登録できませんでした'
          render :make    
        end

      end
      
      def destroy
      end
  
  
    private
      def set_order
        @order = Order.find(params[:id])
        @detail = Detail.new
        @details = Detail.where(order_id:@order.id)

        if params[:action] == "edit" or params[:action] == "update"
          @order.number += 1
        end

        case @c_job.authority_id 
        when 1 then #図書館
          @use_auth = UsersAuthority.find_by(user_id: @order.receive_user_id)

          case @use_auth.authority_id 
            when 2 then #書店
              @user = Store.find_by(user_id: @order.receive_user_id)
            when 3 then #提供者
              @user = Provider.find_by(user_id: @order.receive_user_id)
          end

        else
          @use_auth = UsersAuthority.find_by(user_id: @order.user_id)
          @user = Library.find_by(user_id: @order.user_id)
        end
          select_time(@order)
      end

      def set_search
        @users = User.all.order("id ASC")

        @sub_users = []
        @users.each do |user|
          sub_box = []
          use_auth = UsersAuthority.find_by(user_id: user.id)
          if use_auth.present? && (use_auth.authority_id == 2 or use_auth.authority_id == 3)
            case use_auth.authority_id 
                when 2 then #書店
                  sub_user = Store.find_by(user_id: user.id)
                  sub_box << sub_user.name
                  sub_box << user.id
                  @sub_users << sub_box        
                when 3 then #個人提供者
                  sub_user = Provider.find_by(user_id: user.id)
                  sub_box << sub_user.name
                  sub_box << user.id
                  @sub_users << sub_box        
            end
          end  
        end
      end

      def set_choice

        @books =[]

        if params[:user_id].present?
          @userA = User.find(params[:user_id])
        else
          @userA = @q.result.first
        end

        @use_auth = UsersAuthority.find_by(user_id: @userA.id)

        case @use_auth.authority_id 
          when 2 then #書店
            @sub_user = Store.find_by(user_id: @userA.id)
            @Bosto = BooksStore.where(store_id:@sub_user.id).order("id ASC")

            @Bosto.each do |bost|
              bookA = Book.find(bost.book_id)
              alBos = []
              if bookA.present?
                alBos << bookA.id
                alBos << bookA.name
                alBos << bost.quantity
                alBos << bost.price
                @books << alBos
              end    
            end

          when 3 then #提供者
            @sub_user = Provider.find_by(user_id: @userA.id)
            @Bopro = BooksProvider.where(provider_id:@sub_user.id).order("id ASC")

            @Bopro.each do |bopr|
              bookA = Book.find(bopr.book_id)
              alPro = []
              if bookA.present?
                alPro << bookA.id
                alPro << bookA.name
                alPro << bopr.quantity
                alPro << bopr.hand_flg
                @books << alPro
              end    
            end
        end
      end

      def set_make
        if params[:order][:user_id].nil?
          if params[:user_id].present? && params[:book_ids].nil?
            flash[:notice] = '受発注するデータを選んでください'
            set_choice
            render :choice
          else
            if params[:book_ids].is_a?(String)
              @book_select = params[:book_ids].split
            else
              @book_select = params[:book_ids]
            end
            @userA = User.find(params[:user_id])    
            set_make_unit
          end
        else
          @book_select = params[:order][:book_ids].split
          @userA = User.find(params[:order][:user_id])    
          set_make_unit
        end
      end

      def set_make_unit
        @books =[]
        @use_auth = UsersAuthority.find_by(user_id: @userA.id)

        case @use_auth.authority_id 
          when 2 then #書店
            @sub_user = Store.find_by(user_id: @userA.id)
            @book_select.size.times do |n|
              bosto = BooksStore.find_by(book_id:@book_select[n])
              bookA = Book.find(@book_select[n])
              alBos = []
              if bookA.present?
                alBos << bookA.id
                alBos << bookA.name
                alBos << bosto.quantity
                alBos << bosto.price
                @books << alBos
              end    
            end

          when 3 then #提供者
            @sub_user = Provider.find_by(user_id: @userA.id)
            @book_select.size.times do |n|
              bopro = BooksProvider.find_by(book_id:@book_select[n])
              bookA = Book.find(@book_select[n])
              alPro = []
              if bookA.present?
                alPro << bookA.id
                alPro << bookA.name
                alPro << bopro.quantity
                alPro << bopro.hand_flg
                @books << alPro
              end    
            end
        end
      end

      def select_time_index(order)
        case order.number
        when 1 then 
          order.receive_user_name = "未依頼"
        when 2 then 
          order.receive_user_name = "見積依頼"
        when 3 then 
            order.receive_user_name = "見積完了"
        when 4 then 
            order.receive_user_name = "発注依頼"
        when 5 then 
          if @c_job.authority_id == 1
            order.receive_user_name = "発注完了"
          else
            order.receive_user_name = "納品待ち"
          end
        when 6 then 
            order.receive_user_name = "納品完了"
        when 7 then 
            order.receive_user_name = "受領依頼"
        when 8 then 
            order.receive_user_name = "受領完了"
        when 9 then 
            order.receive_user_name = "請求依頼"
        when 10 then 
          order.receive_user_name = "支払完了"
        when 11 then 
            order.receive_user_name = "領収依頼"
        when 12 then 
          order.receive_user_name = "完了"
        end
      end


      def select_time(order)
        case order.number
        when 1 then 
          @number = "未依頼"
        when 2 then 
          @number = "見積依頼"
        when 3 then 
            @number = "見積完了"
        when 4 then 
            @number = "発注依頼"
        when 5 then 
          if @c_job.authority_id == 1
            @number = "発注完了"
          else
            @number = "納品待ち"
          end
        when 6 then 
            @number = "納品完了"
        when 7 then 
            @number = "受領依頼"
        when 8 then 
            @number = "受領完了"
        when 9 then 
            @number = "請求依頼"
        when 10 then 
          @number = "支払完了"
        when 11 then 
            @number = "領収依頼"
        when 12 then 
          @number = "完了"
        end
      end

      def select_number(order_up)
        case params[:order][:number]
        when "未依頼" then 
          order_up.number = 1
        when "見積依頼" then 
          order_up.number = 2
        when "見積完了" then 
          order_up.number = 3
        when "発注依頼" then 
          order_up.number = 4
        when "発注完了" then 
          order_up.number = 5
        when "納品完了" then 
          order_up.number = 6
        when "受領依頼" then 
          order_up.number = 7
        when "受領完了" then 
          order_up.number = 8
        when "請求依頼" then 
          order_up.number = 9
        when "支払完了" then 
          order_up.number = 10
        when "領収依頼" then 
          order_up.number = 11
        when "完了" then 
          order_up.number = 12
        end
      end

      def set_q
        @q = User.ransack(params[:q])
      end
  
      def order_params
        params.require(:order).permit(:ord_limit, :condition)
      end
      
end
