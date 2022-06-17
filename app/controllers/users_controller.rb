class UsersController < ApplicationController
    skip_before_action :login_required, only: [:new, :create]
    before_action :set_user,  only: [:show, :edit, :update, :destroy]
    before_action :correct_user, only: [:show]
  
      def new
          @user = User.new
      end
  
      def create
        @user = User.new(user_params)

        case params[:authority]
        when "書店" then #書店
          authority = 2
          @sub_user = Store.new(store_params)
          @sub_user.user_id = current_user.id
          
        when "個人提供者" then #個人提供者
          authority = 3
          @sub_user = Provider.new(provider_params)
          @sub_user.user_id = current_user.id
        end

        if @user.save && @sub_user.save

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
    
      def show
        @user = User.find(params[:id])
      end
  
      def edit
      end
  
      def update
          if @user.update(user_params)
            redirect_to user_path(@user.id)
            flash[:notice] = 'アカウントを更新しました'
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
  
      def user_params
        params.require(:user).permit(:number, :password, :password_confirmation)
      end
  
      def store_params
        params.require(:store).permit(:name, :sub_number, :phone, :fax, :manager, :email, :address, :user_id)
      end

      def provider_params
        params.require(:provider).permit(:name, :sub_number, :email, :phone, :address, :user_id)
      end

      def correct_user
        @user = User.find(params[:id])
        redirect_to current_user unless current_user?(@user)
      end
  end

