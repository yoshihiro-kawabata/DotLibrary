class UsersAuthority < ApplicationRecord
  belongs_to :authority
  belongs_to :user
end
