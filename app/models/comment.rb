class Comment < ApplicationRecord
  validates :user_name, presence: true, length: { maximum: 100 }
  validates :content, length: { maximum: 250 }
  belongs_to :order
  belongs_to :user
end
