class Item < ApplicationRecord
  validates :field1,
            presence: true,
            length: { maximum: 10 }

  validates :field2,
            presence: true

  validates :field3,
            presence: true
end
