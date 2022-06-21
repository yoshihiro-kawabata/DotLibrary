class Order < ApplicationRecord
  validates :title, presence: true, length: { maximum: 100 }
  validates :user_id, presence: true
  validates :user_name, presence: true
  validates :receive_user_id, presence: true
  validates :receive_user_name, presence: true
  validates :number, presence: true, length: { maximum: 30 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :limit, presence: true, length: { maximum: 100 }
  validates :condition, presence: true, length: { maximum: 100 }
  validates :title, presence: true, length: { maximum: 100 }
  validates :price, length: { maximum: 30 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  has_many :comments
  has_many :details
  belongs_to :user
end

