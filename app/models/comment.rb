class Comment < ApplicationRecord
  validates :title, presence: true, length: { maximum: 100 }
  validates :content, length: { maximum: 250 }
  belongs_to :order
  belongs_to :user
end
