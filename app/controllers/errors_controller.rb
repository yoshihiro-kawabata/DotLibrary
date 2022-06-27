class ErrorsController < ApplicationController
    skip_before_action :login_required
    skip_before_action :library_required
    skip_before_action :store_required
    skip_before_action :provider_required
    
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from Exception, with: :render_500
    
    def render_404
      render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
    end
    
    def render_500
      render template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html'
    end
  
    def show
     raise
    end

end
