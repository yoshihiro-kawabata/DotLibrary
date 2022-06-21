class SessionsController < ApplicationController
  skip_before_action :login_required, only: [:new, :create]

  def new
  end

  def create
      user = User.find_by(number: params[:session][:number].downcase)
      if user && user.authenticate(params[:session][:password])
        authority = UsersAuthority.find_by(user_id: user.id)

        case authority.authority_id
        when 1 then #司書
          sub_user = Library.find_by(user_id:authority.user_id)
        when 2 then #書店
          sub_user = Store.find_by(user_id:authority.user_id)
        when 3 then #個人提供者
          sub_user = Provider.find_by(user_id:authority.user_id)       
        end
      
        if sub_user
          log_in(user)
          redirect_to mypage_users_path
          flash[:notice] = 'ログインしました'
        else
          flash[:danger] = 'ログインに失敗しました'
          render :new
        end

      else
       flash[:danger] = 'ログインに失敗しました'
        render :new
      end
  end

  def destroy
      session.delete(:user_id)
      flash[:notice] = 'ログアウトしました'
      redirect_to new_session_path
  end
end
