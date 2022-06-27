module SessionsHelper
    def current_user
        @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
        c_job
    end

    def c_job
        @c_job ||= UsersAuthority.find_by(user_id: session[:user_id]) if session[:user_id]
        current_job(@c_job)
    end
    
    def current_job(c_job)
        if c_job.present?
            case c_job.authority_id 
                when 1 then #司書
                  @current_job ||= Library.find_by(user_id: session[:user_id]) if session[:user_id]
                when 2 then #書店
                  @current_job ||= Store.find_by(user_id: session[:user_id]) if session[:user_id]
                when 3 then #個人提供者
                  @current_job ||= Provider.find_by(user_id: session[:user_id]) if session[:user_id]
            end
        end
    end


    def logged_in?
        @current_user.present?
    end

    def log_in(user)
        session[:user_id] = user.id
    end

    def current_user?(user)
        user == @current_user
    end


end
