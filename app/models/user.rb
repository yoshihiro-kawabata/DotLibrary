class User < ApplicationRecord
    validates :number, presence: true, length: { maximum: 30 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}
    has_secure_password
    validates :password, length: { minimum: 6 }
    has_and_belongs_to_many :authorities
    has_many :libraries
    has_many :stores
    has_many :puroviders
    has_many :messages
    has_many :orders
    has_many :comments
end
