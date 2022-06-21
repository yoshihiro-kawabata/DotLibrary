class UsersAuthority < ApplicationRecord
  validates :user_id, uniqueness: true
  belongs_to :authority
  belongs_to :user
end
