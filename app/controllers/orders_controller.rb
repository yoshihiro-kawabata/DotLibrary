class OrdersController < ApplicationController
      before_action :login_required
      skip_before_action :library_required
      before_action :store_required, only: [:choice, :search, :make, :create]
      before_action :provider_required, only: [:choice, :search, :make, :create]
      before_action :set_order, only: [:show, :edit, :update]
      before_action :set_q, only: [:choice, :search, :make, :create]
      before_action :set_search, only: [:choice, :search, :make, :create]
      before_action :set_choice, only: [:choice]
      before_action :set_make, only: [:make, :create]
      before_action :order_required, only: [:show, :edit, :update]

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
          @orders.each do |order|
            talks = Comment.where(order_id: order.id).order("created_at ASC")
            if talks.present? && talks.last.created_at > order.updated_at
              order.receive_user_id = 1
            else
              order.receive_user_id = 0
            end
          end
        else
          @orders = Order.where(receive_user_id: @current_user.id, complete_flg: true).order("updated_at DESC")
          @orders.each do |order|
            talks = Comment.where(order_id: order.id).order("created_at ASC")
            if talks.present? && talks.last.created_at > order.updated_at
              order.receive_user_id = 1
            else
              order.receive_user_id = 0
            end
          end
        end
      end

      def talk
        @order = Order.find(params[:order_id])
        @comment = Comment.new
        @talks = Comment.where(order_id: @order.id).order("created_at ASC")
        order_required

        if @talks.present? && @order.complete_flg? && @talks.last.created_at > @order.updated_at
          @order.update(created_at: DateTime.current)
        end
      end

      def show
      end

      def edit
        if @c_job.authority_id == 1
          if @order.number.in?([3,5,7,9,11,13])
            flash[:notice] = '発注先の更新をお待ちください'
            redirect_to order_path(@order.id)
          end
        else
          if @order.number.in?([1,2,4,6,8,10,12])
            flash[:notice] = '発注元の更新をお待ちください'
            redirect_to order_path(@order.id)
          end
        end
      end
  
      def update

        order_up = @order
        select_number(order_up)              
        case @order.number 
        when 2 then 
          order_up.title = "【" + params[:order][:number] + "】" + @current_job.name + "_" + DateTime.now.strftime('%Y年%m月%d日%H時%M分')

          if params[:order][:number] == "見積依頼（差し戻し）"
            @detail_post = Detail.find_by(order_id: order_up.id, quantity: 0, name: "送料")
            @detail_equip = Detail.find_by(order_id: order_up.id, quantity: 0, name: "装備費")
            @detail_other = Detail.find_by(order_id: order_up.id, quantity: 0, name: "その他")
            order_up.price = order_up.price - @detail_post.price - @detail_equip.price - @detail_other.price

            if @order.update(title: order_up.title, number: order_up.number, price: order_up.price)
              @detail_post.destroy
              @detail_equip.destroy
              @detail_other.destroy
              comment_create(params[:order][:number])
              flash[:notice] = '受発注情報の更新が完了しました'
              redirect_to talk_orders_path(order_id: @order.id)
            else
              flash[:notice] = '受発注情報が更新できませんでした'
              render :edit    
            end
          
          else
            if @order.update(title: order_up.title, number: order_up.number)
              comment_create(params[:order][:number])
              flash[:notice] = '受発注情報の更新が完了しました'
              redirect_to talk_orders_path(order_id: @order.id)
            else
              flash[:notice] = '受発注情報が更新できませんでした'
              render :edit    
            end
          end

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
              comment_create(params[:order][:number])
              flash[:notice] = '受発注情報の更新が完了しました'
              redirect_to talk_orders_path(order_id: @order.id)
            end
          else
            flash[:notice] = '受発注情報が更新できませんでした'
            render :edit    
          end

        when 5 then 
          use_auth = UsersAuthority.find_by(user_id: @order.receive_user_id)
          details = Detail.where(order_id: order_up.id)

          case use_auth.authority_id 
          when 2 then   
            storeA = Store.find_by(user_id: @order.receive_user_id)
            details.each do |detail| #在庫操作
              if detail.quantity > 0

                bookB = BooksStore.select('book_id').where(store_id: storeA.id)
                book = Book.where(id: bookB, name: detail.name)
                bookA = BooksStore.where(book_id: book.ids, store_id: storeA.id)

                if book.present? && bookA.count == 1
                  book_quant = bookA[0].quantity - detail.quantity
                  if book_quant < 0
                    @order.errors.add(detail.name, "：在庫が足りていません。見積完了後に在庫数が減少した可能性があります。")
                    @order.errors.add(detail.name, "：登録している書籍の在庫数を修正してください。")
                  end
                else
                  @order.errors.add(detail.name, "：名前が存在しない、もしくは複数登録されています。")
                  @order.errors.add(detail.name, "：登録している書籍の名前を元に戻してください。")
                end
              end
            end
          when 3 then   
            providerA = Provider.find_by(user_id: @order.receive_user_id)
            details.each do |detail| #在庫操作
              if detail.quantity > 0

                bookB = BooksProvider.select('book_id').where(provider_id:providerA.id)
                book = Book.where(id: bookB, name: detail.name)
                bookA = BooksProvider.where(book_id: book.ids, provider_id:providerA.id)

                if book.present? && bookA.count == 1
                  book_quant = bookA[0].quantity - detail.quantity
                  if book_quant < 0
                    @order.errors.add(detail.name, "：在庫が足りていません。見積完了後に在庫数が減少した可能性があります。")
                    @order.errors.add(detail.name, "：登録している書籍の在庫数を修正してください。")
                  end
                else
                  @order.errors.add(detail.name, "：名前が存在しない、もしくは複数登録されています。")
                  @order.errors.add(detail.name, "：登録している書籍の名前を元に戻してください。")
                end
              end
            end
          end
  
          if @order.errors.present?
            flash[:notice] = '受発注情報が更新できませんでした'
            render :edit
          else

            case use_auth.authority_id 
            when 2 then   
              storeA = Store.find_by(user_id: @order.receive_user_id)
              details.each do |detail| #在庫操作
                if detail.quantity > 0  
                  bookB = BooksStore.select('book_id').where(store_id: storeA.id)
                  book = Book.where(id: bookB, name: detail.name)
                  bookA = BooksStore.where(book_id: book.ids, store_id: storeA.id)
                  book_quant = bookA[0].quantity - detail.quantity
                  bookA[0].update(quantity: book_quant)
                end
              end
            when 3 then   
              providerA = Provider.find_by(user_id: @order.receive_user_id)
              details.each do |detail| #在庫操作
                if detail.quantity > 0
                  bookB = BooksProvider.select('book_id').where(provider_id:providerA.id)
                  book = Book.where(id: bookB, name: detail.name)
                  bookA = BooksProvider.where(book_id: book.ids, provider_id:providerA.id)
                  book_quant = bookA[0].quantity - detail.quantity
                  bookA[0].update(quantity: book_quant)
                end
              end
            end
  
            order_up.title = "【" + params[:order][:number] + "】" + @current_job.name + "_" + DateTime.now.strftime('%Y年%m月%d日%H時%M分')
            if @order.update(title: order_up.title, number: order_up.number)
              comment_create(params[:order][:number])
              flash[:notice] = '受発注情報の更新が完了しました'
              redirect_to talk_orders_path(order_id: @order.id)
            else
              flash[:notice] = '受発注情報が更新できませんでした'
              render :edit    
            end
          end
        when 6 then
          details = Detail.where(order_id: order_up.id).where.not(quantity: 0)
          details.each do |detail|
            if detail.price > 0
              bookD = nil
              bookS = nil
              storeB = Store.find_by(user_id: order_up.receive_user_id)
              selbooks = Book.where(name: detail.name)
              selbooks.each do |selbook|
                bookD = BooksStore.find_by(book_id: selbook.id, store_id: storeB.id)
                if bookD.present?
                  bookS = selbook
                  break
                end
              end

              if bookD.present?
                book = Book.create!(      
                name: detail.name,
                number: detail.id,
                keyword1: "納品元：" + order_up.receive_user_name,
                keyword2: "納品日：" + DateTime.now.strftime('%Y年%m月%d日%H時%M分'),
                keyword3: "備考：" + detail.remark
                )
                bookS.images.each do |image|
                  book.images.attach(image.blob)
                end
              else
                book = Book.create!(      
                  name: detail.name,
                  number: detail.id,
                  keyword1: "納品元：" + order_up.receive_user_name,
                  keyword2: "納品日：" + DateTime.now.strftime('%Y年%m月%d日%H時%M分'),
                  keyword3: "備考：" + detail.remark
                )
              end

              BooksLibrary.create!(
                library_id: @current_job.id, 
                book_id: book.id, 
                quantity: detail.quantity,
                remark: '貸出可能'
              )
            else
              bookD = nil
              bookS = nil
              providerB = Provider.find_by(user_id: order_up.receive_user_id)
              selbooks = Book.where(name: detail.name)
              selbooks.each do |selbook|
                bookD = BooksProvider.find_by(book_id: selbook.id, provider_id: providerB.id)
                if bookD.present?
                  bookS = selbook
                  break
                end
              end

              if bookD.present?
                book = Book.create!(      
                name: detail.name,
                number: detail.id,
                keyword1: "納品元：" + order_up.receive_user_name,
                keyword2: "納品日：" + DateTime.now.strftime('%Y年%m月%d日%H時%M分'),
                keyword3: "備考：" + detail.remark
            )
              bookS.images.each do |image|
                book.images.attach(image.blob)
              end
            else
              book = Book.create!(      
                name: detail.name,
                number: detail.id,
                keyword1: "納品元：" + order_up.receive_user_name,
                keyword2: "納品日：" + DateTime.now.strftime('%Y年%m月%d日%H時%M分'),
                keyword3: "備考：" + detail.remark
            )              
            end
              BooksLibrary.create!(
                library_id: @current_job.id, 
                book_id: book.id, 
                quantity: detail.quantity,
                remark: detail.remark
              )
            end
          end
          order_up.title = "【" + params[:order][:number] + "】" + @current_job.name + "_" + DateTime.now.strftime('%Y年%m月%d日%H時%M分')
          if @order.update(title: order_up.title, number: order_up.number)
            comment_create(params[:order][:number])
            flash[:notice] = '受発注情報の更新が完了しました'
            redirect_to talk_orders_path(order_id: @order.id)
          else
            flash[:notice] = '受発注情報が更新できませんでした'
            render :edit    
          end

        when 13 then 
          order_up.title = "【" + params[:order][:number] + "】" + @current_job.name + "_" + DateTime.now.strftime('%Y年%m月%d日%H時%M分')
          order_up.complete_flg = true
          if @order.update(title: order_up.title, number: order_up.number, complete_flg: order_up.complete_flg)
            comment_create(params[:order][:number])
            flash[:notice] = '受発注が完了しました'
            redirect_to orders_path
          else
            flash[:notice] = '受発注情報が更新できませんでした'
            render :edit    
          end
        
        when 14 then 
          details = Detail.where(order_id: order_up.id).where.not(quantity: 0)
          details.each do |detail|
            if detail.price > 0
              bookD = nil
              storeB = Store.find_by(user_id: order_up.receive_user_id)
              selbooks = Book.where(name: detail.name)
              selbooks.each do |selbook|
                bookD = BooksStore.find_by(book_id: selbook.id, store_id: storeB.id)
                if bookD.present?
                  qubo = bookD.quantity + detail.quantity
                  bookD.update(quantity: qubo)
                  break
                end
              end
            else
              bookD = nil
              providerB = Provider.find_by(user_id: order_up.receive_user_id)
              selbooks = Book.where(name: detail.name)
              selbooks.each do |selbook|
                bookD = BooksProvider.find_by(book_id: selbook.id, provider_id: providerB.id)
                if bookD.present?
                  qubo = bookD.quantity + detail.quantity
                  bookD.update(quantity: qubo)
                  break
                end
              end
            end
          end

          order_up.title = "【" + params[:order][:number] + "】" + @current_job.name + "_" + DateTime.now.strftime('%Y年%m月%d日%H時%M分')
          order_up.complete_flg = true
          order_up.number = 14
          if @order.update(title: order_up.title, number: order_up.number, complete_flg: order_up.complete_flg)
            comment_create(params[:order][:number])
            flash[:notice] = '受発注が完了しました'
            redirect_to orders_path
          else
            flash[:notice] = '受発注情報が更新できませんでした'
            render :edit    
          end
  
        when 15 then 
          details = Detail.where(order_id: order_up.id).where.not(quantity: 0)
          details.each do |detail|
            if detail.price > 0
              bookD = nil
              storeB = Store.find_by(user_id: order_up.receive_user_id)
              selbooks = Book.where(name: detail.name)
              selbooks.each do |selbook|
                bookD = BooksStore.find_by(book_id: selbook.id, store_id: storeB.id)
                if bookD.present?
                  qubo = bookD.quantity + detail.quantity
                  bookD.update(quantity: qubo)
                  break
                end
              end
  
            else
              bookD = nil
              providerB = Provider.find_by(user_id: order_up.receive_user_id)
              selbooks = Book.where(name: detail.name)
              selbooks.each do |selbook|
                bookD = BooksProvider.find_by(book_id: selbook.id, provider_id: providerB.id)
                if bookD.present?
                  qubo = bookD.quantity + detail.quantity
                  bookD.update(quantity: qubo)  
                  break
                end
              end
            end
          end

          order_up.title = "【" + params[:order][:number] + "】" + @current_job.name + "_" + DateTime.now.strftime('%Y年%m月%d日%H時%M分')
          order_up.number = 4
          if @order.update(title: order_up.title, number: order_up.number)
            comment_create(params[:order][:number])
            flash[:notice] = '受発注情報の更新が完了しました'
            redirect_to orders_path
          else
            flash[:notice] = '受発注情報が更新できませんでした'
            render :edit    
          end
  
        else
          order_up.title = "【" + params[:order][:number] + "】" + @current_job.name + "_" + DateTime.now.strftime('%Y年%m月%d日%H時%M分')
          if @order.update(title: order_up.title, number: order_up.number)
            comment_create(params[:order][:number])
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
                  if params[:order][:quantities][n].to_i < 1
                    @detail.errors.add(bookA.name, "：希望数量は1以上在庫数以下で指定してください")
                    @detail_n.quantity = 0
                  elsif params[:order][:quantities][n].to_i > bosto.quantity
                    @detail.errors.add(bookA.name, "：希望数量が既存在庫数を上回っています")
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
                  if params[:order][:quantities][n].to_i < 1
                    @detail.errors.add(bookA.name, "：希望数量は1以上在庫数以下で指定してください")
                    @detail_n.quantity = 0
                  elsif params[:order][:quantities][n].to_i > bopro.quantity
                    @detail.errors.add(bookA.name, "：希望数量が既存在庫数を上回っています")
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
            if @order.number = 2
              comment_create(params[:order][:number])
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
        if params[:id] == "make"
          flash[:notice] = '受発注検索画面に移動します'
          redirect_to search_orders_path
        else

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

          if params[:action] == "show"
            select_time_index(@order)
          else
            select_time(@order)
          end
        end
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
              if bookA.present? && bost.quantity > 0
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
              if bookA.present? && bopr.quantity > 0
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
        books_name =[]
        count_box =[]
        name_count = 0
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
                books_name << bookA.name
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
                books_name << bookA.name
                alPro << bookA.name
                alPro << bopro.quantity
                alPro << bopro.hand_flg
                @books << alPro
              end    
            end
        end

        books_name.size.times do |n|
          count_A = books_name.count{ |x| x == books_name[n] }
          count_box << count_A
        end

        if count_box.max > 1
          flash[:notice] = '同じ名前の書籍を発注することは出来ません'
          set_choice
          render :choice
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
            order.receive_user_name = "発注完了"
        when 6 then 
            order.receive_user_name = "納品完了"
        when 7 then 
            order.receive_user_name = "受領申請"
        when 8 then 
            order.receive_user_name = "受領完了"
        when 9 then 
            order.receive_user_name = "請求申請"
        when 10 then 
          order.receive_user_name = "支払完了"
        when 11 then 
            order.receive_user_name = "領収申請"
        when 12 then 
          order.receive_user_name = "領収完了"
        when 13 then 
          order.receive_user_name = "完了"
        when 14 then 
          order.receive_user_name = "未納終了"
        when 15 then 
          order.receive_user_name = "未納差し戻し"
        end
      end


      def select_time(order)
        case order.number
        when 1 then 
          @number = ["未依頼", "取引終了"]
        when 2 then 
          @number = ["見積依頼", "取引終了"]
        when 3 then 
            @number = ["見積完了", "取引終了"]
        when 4 then 
            @number = ["発注依頼","見積依頼（差し戻し）", "取引終了"]
        when 5 then 
            @number = ["発注完了", "取引終了"]
        when 6 then 
            @number = ["納品完了", "未納終了", "未納差し戻し"]
        when 7 then 
            @number = ["受領申請","請求申請","領収申請", "取引終了"]
        when 8 then 
            @number = ["受領完了", "取引終了"]
        when 9 then 
            @number = ["受領申請","請求申請","領収申請", "取引終了"]
        when 10 then 
            @number = ["支払完了", "取引終了"]
        when 11 then 
            @number = ["受領申請","請求申請","領収申請", "取引終了"]
        when 12 then 
            @number = ["領収完了", "取引終了"]
        when 13 then 
            @number = ["受領申請","請求申請","領収申請","完了"]
        end
      end

      def select_number(order_up)
        case params[:order][:number]
        when "未依頼" then 
          order_up.number = 1
        when "見積依頼" then 
          order_up.number = 2
        when "見積依頼（差し戻し）" then 
          order_up.number = 2
        when "見積完了" then 
          order_up.number = 3
        when "発注依頼" then 
          order_up.number = 4
        when "発注完了" then 
          order_up.number = 5
        when "納品完了" then 
          order_up.number = 6
        when "受領申請" then 
          order_up.number = 7
        when "受領完了" then 
          order_up.number = 8
        when "請求申請" then 
          order_up.number = 9
        when "支払完了" then 
          order_up.number = 10
        when "領収申請" then 
          order_up.number = 11
        when "領収完了" then 
          order_up.number = 12
        when "完了" then 
          order_up.number = 13
        when "取引終了" then 
          order_up.number = 13
        when "未納終了" then 
          order_up.number = 14
        when "未納差し戻し" then 
          order_up.number = 15
        end
      end

      def order_required
        unless @current_user.id == @order.user_id or @current_user.id == @order.receive_user_id
          redirect_to mypage_users_path, notice: '受発注画面に遷移できませんでした'
        end

        if @current_user.id == @order.receive_user_id && @order.number < 2
          redirect_to mypage_users_path, notice: '受発注画面に遷移できませんでした'
        end
      end

      def set_q
        @q = User.ransack(params[:q])
      end
  
      def order_params
        params.require(:order).permit(:ord_limit, :condition)
      end

      def comment_create(number)
        Comment.create!(
          user_name: @current_job.name,
          content: "受発注データを更新しました。" + "\n進捗状況：" + number + "\n更新者：" + @current_job.name + "\n更新時間：" + DateTime.now.strftime('%Y年%m月%d日%H時%M分'),
          order_id: @order.id,
          user_id: @current_user.id
        )
      end
end
