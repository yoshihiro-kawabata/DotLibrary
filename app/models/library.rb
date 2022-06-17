class Library < ApplicationRecord
  validates :name, presence: true, length: { maximum: 30 }
  validates :sub_number, presence: true, length: { maximum: 30 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  before_validation { email.downcase! }
  validates :phone, presence: true, length: { maximum: 20 }
  validates :address, presence: true, length: { maximum: 200 }
  has_and_belongs_to_many :books
  belongs_to :user
end
