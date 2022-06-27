class ApplicationController < ActionController::Base
    include SessionsHelper
    before_action :login_required
    before_action :library_required
    before_action :store_required
    before_action :provider_required

    private

    def login_required
      redirect_to new_session_path, notice: 'ログインしてください。'  unless current_user
    end

    def library_required
      redirect_to mypage_users_path, notice: '処理できない画面に遷移しました'  if current_library?(@c_job)
    end    

    def store_required
      redirect_to mypage_users_path, notice: '処理できない画面に遷移しました'  if current_store?(@c_job)
    end

    def provider_required
      redirect_to mypage_users_path, notice: '処理できない画面に遷移しました'  if current_provider?(@c_job)
    end

end
