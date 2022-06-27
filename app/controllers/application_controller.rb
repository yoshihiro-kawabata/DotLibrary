class ApplicationController < ActionController::Base
    include SessionsHelper
    before_action :login_required

    private

    def login_required
      redirect_to new_session_path, notice: 'ログインしてください。'  unless current_user
    end

end
