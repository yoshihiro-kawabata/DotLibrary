class Message < ApplicationRecord
  validates :content, length: { maximum: 200 }
  belongs_to :user
end
