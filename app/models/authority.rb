class Authority < ApplicationRecord
    validates :level, presence: true, length: { maximum: 30 }, numericality: {only_integer: true, greater_than_or_equal_to: 0}
    validates :name, presence: true, length: { maximum: 30 }
    has_and_belongs_to_many :users
end
