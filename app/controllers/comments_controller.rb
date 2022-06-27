class CommentsController < ApplicationController
    before_action :login_required
    skip_before_action :library_required
    skip_before_action :store_required
    skip_before_action :provider_required

    def create
        @comment = Comment.new(comment_params)
        @order = Order.find(params[:comment][:order_id])
        @comment.user_name = @current_job.name
        @comment.order_id = @order.id
        @comment.user_id = @current_user.id

        if @comment.save
            redirect_to talk_orders_path(order_id: @order.id)
          else
            flash[:notice] = 'コメントできませんでした'
            redirect_to talk_orders_path(order_id: @order.id)
          end
  
    
    end

    private
    def comment_params
      params.require(:comment).permit(:content)
    end
    
end
