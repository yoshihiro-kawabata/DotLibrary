class BooksProvider < ApplicationRecord
  validates :quantity, presence: true, length: { maximum: 50 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}  
  belongs_to :provider
  belongs_to :book
end
