class Book < ApplicationRecord
    validates :name, presence: true, length: { maximum: 100 }
    validates :number, presence: true, length: { maximum: 50 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}  
    validates :keyword1, length: { maximum: 100 }
    validates :keyword2, length: { maximum: 100 }
    validates :keyword3, length: { maximum: 100 }
    validates :keyword4, length: { maximum: 100 }
    validates :keyword5, length: { maximum: 100 }
    has_many_attached :portrait
end
