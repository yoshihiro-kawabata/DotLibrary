class OrdersController < ApplicationController
      before_action :login_required
      before_action :set_q, only: [:choice, :search, :make, :create]
      before_action :set_search, only: [:choice, :search, :make, :create]
      before_action :set_choice, only: [:choice]
      before_action :set_make, only: [:make, :create]
  
      def search
      end

      def choice
      end

      def make
        @order = Order.new
      end

      def new
      end
  
      def create
        flash[:notice] = '戻った'
        render :make
      end
    
      def commit
      end

      def show
      end
  
      def edit
      end
  
      def update
      end
  
      def destroy
      end
  
  
    private
      def set_user
        @user = User.find(params[:id])
      end

      def set_search
        @users = User.all

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

      def set_make
        if params[:order][:user_id].nil?
          if params[:user_id].present? && params[:book_ids].nil?
            flash[:notice] = '受発注するデータを選んでください'
            redirect_to search_orders_path
          else
            @book_select = params[:book_ids]
            @userA = User.find(params[:user_id])    
            set_make_unit
          end
        else
          @book_select = params[:order][:book_ids]
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

      def set_choice
        @books =[]

        @userA = @q.result.first
        @use_auth = UsersAuthority.find_by(user_id: @userA.id)

        case @use_auth.authority_id 
          when 2 then #書店
            @sub_user = Store.find_by(user_id: @userA.id)
            @Bosto = BooksStore.where(store_id:@sub_user.id)

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
            @Bopro = BooksProvider.where(provider_id:@sub_user.id)

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

      def set_sub_user
      end

      def set_q
        @q = User.ransack(params[:q])
      end
  
      def user_params
        params.require(:user).permit(:number, :password, :password_confirmation)
      end

      def library_params
        params.require(:user).permit(:name, :sub_number, :email, :phone, :address)
      end
      
      def store_params
        params.require(:user).permit(:name, :sub_number, :phone, :fax, :manager, :email, :address)
      end

      def provider_params
        params.require(:user).permit(:name, :sub_number, :email, :phone, :address)
      end

end
