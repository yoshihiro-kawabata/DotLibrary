class BooksController < ApplicationController
    before_action :login_required
    before_action :set_book, only: [:show, :edit, :update]
    before_action :set_q, only: [:index, :search]
        
    def index
      @books =[]
        @q.result.each do |book|
          alBos = []
          case @c_job.authority_id 
            when 1 then #司書
              alBoSto = BooksStore.find_by(book_id:book.id)
            when 2 then #書店
              alBoSto = BooksStore.find_by(book_id:book.id, store_id:@current_job.id)
            when 3 then #提供者
              alBoSto = nil
          end
          if alBoSto.present?
            alBos << book.name
            alBos << book.keyword1
            alBos << book.keyword2
            alBos << book.keyword3
            alBos << book.keyword4
            alBos << book.keyword5
            alBos << alBoSto.quantity
            alBos << alBoSto.price
            alBos << "---"
            alBos << book.id
            @books << alBos
          end    

          alBop = []
          case @c_job.authority_id 
          when 1 then #司書
            alBoPro = BooksProvider.find_by(book_id:book.id)
          when 2 then #書店
            alBoPro = nil
          when 3 then #提供者
            alBoPro = BooksProvider.find_by(book_id:book.id, provider_id:@current_job.id)
          end
          if alBoPro.present?
            alBop << book.name
            alBop << book.keyword1
            alBop << book.keyword2
            alBop << book.keyword3
            alBop << book.keyword4
            alBop << book.keyword5
            alBop << alBoPro.quantity
            alBop << "---"
            alBop << alBoPro.hand_flg
            alBop << book.id
            @books << alBop
          end
        end
      end
      
    def search
      @books =[]
        @q.result.each do |book|
          alBos = []
          case @c_job.authority_id 
            when 1 then #司書
              alBoSto = BooksStore.find_by(book_id:book.id)
            when 2 then #書店
              alBoSto = BooksStore.find_by(book_id:book.id, store_id:@current_job.id)
            when 3 then #提供者
              alBoSto = nil
          end
          if alBoSto.present?
            alBos << book.name
            alBos << book.keyword1
            alBos << book.keyword2
            alBos << book.keyword3
            alBos << book.keyword4
            alBos << book.keyword5
            alBos << alBoSto.quantity
            alBos << alBoSto.price
            alBos << "---"
            alBos << book.id
            @books << alBos
          end    

          alBop = []
          case @c_job.authority_id 
          when 1 then #司書
            alBoPro = BooksProvider.find_by(book_id:book.id)
          when 2 then #書店
            alBoPro = nil
          when 3 then #提供者
            alBoPro = BooksProvider.find_by(book_id:book.id, provider_id:@current_job.id)
          end
          if alBoPro.present?
            alBop << book.name
            alBop << book.keyword1
            alBop << book.keyword2
            alBop << book.keyword3
            alBop << book.keyword4
            alBop << book.keyword5
            alBop << alBoPro.quantity
            alBop << "---"
            alBop << alBoPro.hand_flg
            alBop << book.id
            @books << alBop
          end
        end
      end

    def show
      bookA = BooksStore.find_by(book_id:@book.id)
      bookB = BooksProvider.find_by(book_id:@book.id)

      if bookA.present?
        @user_flg = true
        @user = Store.find(bookA.store_id)
        @sub_book = bookA
      end

      if bookB.present?
        @user_flg = false
        @user = Provider.find(bookB.provider_id)
        @sub_book = bookB
      end
    end

    def new
      @book = Book.new
      @sub_book = Book.new
    end
  
    def create
      @book = Book.new(book_params)

      case @c_job.authority_id 
        when 2 then #書店
          @sub_book = BooksStore.new(store_params)
          @sub_book.store_id = @current_job.id
        when 3 then #提供者
          @sub_book = BooksProvider.new(provider_params)
          if params[:book][:hand_flg] == "譲渡可能"
            @sub_book.hand_flg = true
          else
            @sub_book.hand_flg = false
          end
            @sub_book.provider_id = @current_job.id
      end

      bookA = Book.first.id
      @sub_book.book_id = bookA

      if @book.valid? && @sub_book.valid?

        @book.save
        @sub_book.book_id = @book.id
        @sub_book.save

        redirect_to books_path
        flash[:notice] = '書籍を登録しました'
      else
        flash[:notice] = '書籍を登録出来ませんでした'
        render :new
      end
    end

    def edit
      bookA = BooksStore.find_by(book_id:@book.id)
      bookB = BooksProvider.find_by(book_id:@book.id)

      if bookA.present?
        @user_flg = true
        @user = Store.find(bookA.store_id)
        @sub_book = bookA
      end

      if bookB.present?
        @user_flg = false
        @user = Provider.find(bookB.provider_id)
        @sub_book = bookB
      end
    end
  
    def update
      bookA = BooksStore.find_by(book_id:@book.id)
      bookB = BooksProvider.find_by(book_id:@book.id)

      if bookA.present?
        @user_flg = true
        @user = Store.find(bookA.store_id)
        @sub_book = bookA
        @sub_book.quantity = params[:book][:quantity]
        @sub_book.price = params[:book][:price]
        @sub_book.limit = params[:book][:limit]
      end

      if bookB.present?
        @user_flg = false
        @user = Provider.find(bookB.provider_id)
        @sub_book = bookB
        @sub_book.quantity = params[:book][:quantity]
        if params[:book][:hand_flg] == "譲渡可能"
          @sub_book.hand_flg = true
        else
          @sub_book.hand_flg = false
        end
      end

      if params[:book][:image_ids].present? && params[:book][:images].present?
        flash[:notice] = '書籍情報を更新出来ませんでした'
        @book.errors.add(:images, "の削除、追加の操作は同時に行えません")
        render :edit
      else
        if @book.valid? && @sub_book.valid?

          if params[:book][:images].present? && params[:book][:images].count > 4            
            flash[:notice] = '書籍情報を更新出来ませんでした'
            @book.errors.add(:add_images, "は4枚以内にしてください")
            render :edit
          else
            # 画像の削除処理
            params[:book][:image_ids]&.each do |image_id|
              @book.images.find(image_id).purge
            end

            if @book.update(book_params)

              case @c_job.authority_id
                when 2 then #書店
                  @sub_book.update(store_params)
                when 3 then #個人提供者
                  @sub_book.update(provider_params)
              end
                redirect_to book_path(@book.id)
                flash[:notice] = '書籍情報を更新しました'
            else
              flash[:notice] = '書籍情報を更新出来ませんでした'
              render :edit
            end
          end
        else
          flash[:notice] = '書籍情報を更新出来ませんでした'
          render :edit
        end
      end
    end
    
  private
      def set_book
        @book = Book.find(params[:id])
      end

      def book_params
        params.require(:book).permit(:name, :number, :keyword1, :keyword2, :keyword3, :keyword4, :keyword5, images:[])
      end        

      def store_params
        params.require(:book).permit(:quantity, :price, :limit)
      end

      def provider_params
        params.require(:book).permit(:quantity)
      end


      def set_q
        @q = Book.ransack(params[:q])
      end
end
