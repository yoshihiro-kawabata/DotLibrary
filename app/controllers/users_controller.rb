class UsersController < ApplicationController
    before_action :login_required
    before_action :set_user,  only: [:show, :edit, :update, :destroy]
    before_action :set_sub_user,  only: [:show, :edit, :update]
    before_action :correct_user, only: [:new, :edit, :show]
  
      def index
        @users = User.all

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
          sub_box << sub_user.address
          sub_box << user.id
          @sub_users << sub_box
        end
      end

      def new
          @user = User.new

          if params[:user].present?
            case params[:user][:authority]
            when "書店" then #書店
              @sub_user = Store.new            
            when "個人提供者" then #個人提供者
              @sub_user = Provider.new
            else
              @sub_user =  User.new              
            end
          else
            @sub_user =  User.new
          end
      end
  
      def create
        current_user
        @user = User.new(user_params)

        case params[:user][:authority]
        when "書店" then #書店
          authority = 2
          @sub_user = Store.new(store_params)
          @sub_user.user_id = @current_user.id
          
        when "個人提供者" then #個人提供者
          authority = 3
          @sub_user = Provider.new(provider_params)
          @sub_user.user_id = @current_user.id
        end

        if @user.valid? && @sub_user.valid?

          @user.save && @sub_user.save

          authorityA = Authority.find(authority)
          UsersAuthority.create!(user_id:@user.id, authority_id:authorityA.id)
          @sub_user.update(user_id: @user.id)

          redirect_to user_path(@user.id)
          flash[:notice] = 'アカウントを登録しました'
        else
          flash[:notice] = 'アカウントを登録出来ませんでした'
          render :new
        end
      end
    
      def mypage
        @user = User.find(@current_user.id)
        @messages = Message.where(user_id: @current_user.id,read_flg: false).count 
        set_sub_user
      end

      def show
      end
  
      def edit
      end
  
      def update
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]


        @sub_user.name = params[:user][:name]
        @sub_user.sub_number = params[:user][:sub_number]
        @sub_user.phone = params[:user][:phone]
        @sub_user.email = params[:user][:email]
        @sub_user.address = params[:user][:address]

        if params[:user][:authority] == 2
          @sub_user.fax = params[:user][:fax]
          @sub_user.manager = params[:user][:manager]
        end
        
        if @user.valid? && @sub_user.valid?

          if @user.update(user_params)

            case params[:user][:authority]
              when "司書" then #司書
                @sub_user.update(library_params)
              when "書店" then #書店
                @sub_user.update(store_params)
              when "個人提供者" then #個人提供者
                @sub_user.update(provider_params)
            end
              redirect_to mypage_users_path
              flash[:notice] = 'アカウントを更新しました'
          else
            flash[:notice] = 'アカウントを更新出来ませんでした'
            render :edit
          end
        else
          flash[:notice] = 'アカウントを更新出来ませんでした'
          render :edit
        end
      end
  
      def destroy
      end
  
  
    private
      def set_user
        @user = User.find(params[:id])
      end

      def set_sub_user
        @use_auth = UsersAuthority.find_by(user_id: @user.id)
        case @use_auth.authority_id 
              when 1 then #司書
                @sub_user = Library.find_by(user_id: @user.id)
              when 2 then #書店
                @sub_user = Store.find_by(user_id: @user.id)
              when 3 then #個人提供者
                @sub_user = Provider.find_by(user_id: @user.id)
              else
                @sub_user = nil  
        end
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

      def correct_user
        redirect_to mypage_users_path unless current_user?(@user)
      end
  
  end
