class Detail < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :quantity, length: { maximum: 50 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}  
  validates :price, length: { maximum: 50 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}  
  validates :remark, presence: true
  belongs_to :order
end
