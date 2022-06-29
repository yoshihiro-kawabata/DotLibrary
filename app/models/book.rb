class Book < ApplicationRecord
    validates :name, presence: true, length: { maximum: 100 }
    validates :number, presence: true, length: { maximum: 50 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}  
    validates :keyword1, length: { maximum: 100 }
    validates :keyword2, length: { maximum: 100 }
    validates :keyword3, length: { maximum: 100 }
    validates :keyword4, length: { maximum: 100 }
    validates :keyword5, length: { maximum: 100 }
    has_many_attached :images


    validates :images,
    size: { less_than_or_equal_to: 5.megabytes },              # ファイルサイズ
    dimension: { width: { max: 2000 }, height: { max: 2000 } } # 画像の大きさ

    validate :images_length
    validate :images_content

    def images_length
        if images.length > 4
          errors.add(:images, "は4枚以内にしてください")
        end
      end

    def images_content
      err_count = 0
      images.each do |image|
        unless File.extname(image.filename.to_s.downcase).in?(['.gif', '.png', '.jpg', '.jpeg'])
          err_count += 1
        end
      end
      if err_count > 0
        errors.add(:images, "はgit,png,jpg,jpegのみ登録できます")
      end
    end

end
