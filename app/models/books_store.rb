class BooksStore < ApplicationRecord
  validates :quantity, presence: true, length: { maximum: 50 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}  
  validates :price, presence: true, length: { maximum: 50 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}  
  validates :rimit, length: { maximum: 100 }
  belongs_to :store
  belongs_to :book
end
